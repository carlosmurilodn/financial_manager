require "base64"
require "json"
require "net/http"
require "open3"
require "tempfile"

class OpenaiInvoiceAnalyzer
  API_URL = "https://api.openai.com/v1/responses"
  DEFAULT_MODEL = "gpt-4o-mini"
  IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/jpg image/webp image/gif].freeze
  PDF_CONTENT_TYPES = %w[application/pdf].freeze

  Result = Struct.new(:items, :errors, keyword_init: true)
  AnalysisFile = Struct.new(:io, :content_type, :original_filename, keyword_init: true)

  def initialize(file:, card_id:, due_date:, invoice_password: nil, categories:)
    @file = file
    @card_id = card_id.presence
    @due_date = due_date.presence
    @invoice_password = invoice_password.presence
    @categories = categories
  end

  def call
    return Result.new(items: [], errors: ["Configure a variável OPENAI_API_KEY para analisar PDF ou imagem com IA."]) if api_key.blank?
    return Result.new(items: [], errors: ["Formato de arquivo não suportado pela análise com IA."]) unless supported_file?

    prepared_file = prepare_file
    return prepared_file if prepared_file.is_a?(Result)

    @analysis_file = prepared_file
    response = request_analysis
    return api_error(response) unless response.is_a?(Net::HTTPSuccess)

    items = normalize_items(JSON.parse(extract_output_text(JSON.parse(response.body))))
    Result.new(items: items, errors: items.blank? ? ["A IA não identificou lançamentos na fatura."] : [])
  rescue JSON::ParserError
    Result.new(items: [], errors: ["A IA retornou uma resposta fora do formato esperado."])
  rescue StandardError => error
    Result.new(items: [], errors: ["Não foi possível analisar a fatura com IA: #{error.message}"])
  ensure
    close_analysis_file
    decrypted_file&.close!
    file.rewind if file.respond_to?(:rewind)
  end

  private

  attr_reader :file, :card_id, :due_date, :invoice_password, :categories, :analysis_file, :decrypted_file

  def request_analysis
    uri = URI(API_URL)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 90) do |http|
      http.request(request)
    end
  end

  def payload
    {
      model: ENV.fetch("OPENAI_INVOICE_MODEL", DEFAULT_MODEL),
      input: [
        {
          role: "user",
          content: [
            file_content,
            {
              type: "input_text",
              text: prompt
            }
          ]
        }
      ],
      text: {
        format: {
          type: "json_schema",
          name: "invoice_import",
          strict: true,
          schema: response_schema
        }
      },
      temperature: 0
    }
  end

  def file_content
    encoded_file = Base64.strict_encode64(analysis_file.io.read)
    analysis_file.io.rewind if analysis_file.io.respond_to?(:rewind)

    if pdf_file?
      {
        type: "input_file",
        filename: analysis_file.original_filename,
        file_data: "data:application/pdf;base64,#{encoded_file}"
      }
    else
      {
        type: "input_image",
        image_url: "data:#{analysis_file.content_type};base64,#{encoded_file}",
        detail: "high"
      }
    end
  end

  def prepare_file
    return original_analysis_file unless pdf_file? && invoice_password.present?
    return missing_qpdf_result unless qpdf_available?

    unlock_pdf
  end

  def original_analysis_file
    AnalysisFile.new(
      io: file,
      content_type: file.content_type,
      original_filename: file.original_filename
    )
  end

  def unlock_pdf
    @decrypted_file = Tempfile.new(["invoice-decrypted", ".pdf"], binmode: true)
    decrypted_file.close

    _stdout, stderr, status = Open3.capture3(
      "qpdf",
      "--password=#{invoice_password}",
      "--decrypt",
      file.tempfile.path,
      decrypted_file.path
    )

    return invalid_password_result unless status.success?

    AnalysisFile.new(
      io: File.open(decrypted_file.path, "rb"),
      content_type: "application/pdf",
      original_filename: unlocked_filename
    )
  rescue Errno::ENOENT
    missing_qpdf_result
  end

  def prompt
    <<~PROMPT
      Analise esta fatura de cartão e extraia somente compras à vista feitas em estabelecimentos.
      Ignore compras parceladas, parcelas, pagamentos, pagamento de fatura, boletos, subtotais, totais, cabeçalhos, rodapés, encargos informativos e saldos.

      Regras:
      - Linhas como "PAGAMENTO DE FATURA VIA BOLETO", "Subtotal dos lançamentos", "Total geral dos lançamentos" e "Picpay Card final" não são despesas e não devem aparecer.
      - Use datas no formato dd/mm/aaaa.
      - Use valores no formato brasileiro, sem "R$" quando possível, por exemplo 123,45.
      - Sugira category_id escolhendo apenas uma das categorias disponíveis.
      - Se não houver boa categoria, use category_id vazio.
      - payment_method deve ser sempre credito_a_vista.
      - card_id padrão: #{card_id || "vazio"}.
      - due_date padrão: #{due_date || "vazio"}.

      Categorias disponíveis:
      #{categories.map { |category| "- #{category.id}: #{category.display_name}" }.join("\n")}
    PROMPT
  end

  def response_schema
    {
      type: "object",
      additionalProperties: false,
      properties: {
        items: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            properties: {
              description: { type: "string" },
              amount: { type: "string" },
              date: { type: "string" },
              due_date: { type: "string" },
              category_id: { type: "string" },
              payment_method: { type: "string", enum: Expense.payment_methods.keys },
              card_id: { type: "string" },
              status: { type: "string" }
            },
            required: %w[description amount date due_date category_id payment_method card_id status]
          }
        }
      },
      required: %w[items]
    }
  end

  def normalize_items(parsed)
    parsed.fetch("items", []).filter_map do |item|
      next if item["description"].blank? || item["amount"].blank?
      next if ignored_entry?(item["description"])
      next unless item["payment_method"].blank? || item["payment_method"] == "credito_a_vista"

      {
        description: item["description"].to_s.squish,
        amount: item["amount"].to_s.squish,
        date: item["date"].to_s.squish,
        due_date: item["due_date"].presence || due_date,
        category_id: item["category_id"].presence,
        payment_method: "credito_a_vista",
        card_id: item["card_id"].presence || card_id,
        status: item["status"].presence || "Revisar"
      }
    end
  end

  def extract_output_text(body)
    body["output_text"].presence || body.fetch("output", []).flat_map { |output| output["content"].to_a }.filter_map { |content| content["text"] }.join
  end

  def supported_file?
    pdf_file? || image_file?
  end

  def pdf_file?
    PDF_CONTENT_TYPES.include?(file.content_type) || File.extname(file.original_filename).downcase == ".pdf"
  end

  def image_file?
    IMAGE_CONTENT_TYPES.include?(file.content_type)
  end

  def api_error(response)
    body = JSON.parse(response.body)
    message = body.dig("error", "message") || "Erro #{response.code} na API da OpenAI."
    Result.new(items: [], errors: [message])
  rescue JSON::ParserError
    Result.new(items: [], errors: ["Erro #{response.code} na API da OpenAI."])
  end

  def api_key
    ENV["OPENAI_API_KEY"]
  end

  def qpdf_available?
    system("qpdf", "--version", out: File::NULL, err: File::NULL)
  end

  def missing_qpdf_result
    Result.new(
      items: [],
      errors: ["Esta fatura parece exigir senha, mas o qpdf não está instalado no servidor para desbloquear PDFs protegidos."]
    )
  end

  def invalid_password_result
    Result.new(
      items: [],
      errors: ["Não foi possível abrir a fatura. Verifique a senha informada."]
    )
  end

  def unlocked_filename
    "#{File.basename(file.original_filename, ".*")}_desbloqueada.pdf"
  end

  def close_analysis_file
    return if analysis_file.blank? || analysis_file.io == file

    analysis_file.io.close unless analysis_file.io.closed?
  end

  def ignored_entry?(description)
    normalized = description.to_s.parameterize(separator: " ")
    ignored_terms.any? { |term| normalized.include?(term) }
  end

  def ignored_terms
    [
      "pagamento de fatura",
      "pagamento fatura",
      "pagamento",
      "subtotal",
      "total geral",
      "total dos lancamentos",
      "total de lancamentos",
      "saldo anterior",
      "saldo atual",
      "boleto",
      "final"
    ]
  end
end
