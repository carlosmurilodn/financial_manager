require "base64"
require "json"
require "net/http"
require "open3"
require "tempfile"

class LocalInvoiceAnalyzer
  API_URL = ENV.fetch("LOCAL_INVOICE_AI_URL", "http://localhost:11434/api/chat")
  DEFAULT_MODEL = ENV.fetch("LOCAL_INVOICE_MODEL", "ministral-3:8b")
  IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/jpg image/webp image/gif].freeze
  PDF_CONTENT_TYPES = %w[application/pdf].freeze

  Result = Struct.new(:items, :errors, keyword_init: true)

  def initialize(file:, card_id:, due_date:, invoice_password: nil, categories:)
    @file = file
    @card_id = card_id.presence
    @due_date = due_date.presence
    @invoice_password = invoice_password.presence
    @categories = categories
  end

  def call
    return Result.new(items: [], errors: [ "Formato de arquivo não suportado pela IA local." ]) unless supported_file?
    return Result.new(items: [], errors: [ "Ollama não está respondendo em #{API_URL}. Verifique se o serviço local está ativo." ]) unless ollama_available?

    response = request_analysis
    return api_error(response) unless response.is_a?(Net::HTTPSuccess)

    items = normalize_items(JSON.parse(extract_message(JSON.parse(response.body))))
    Result.new(items: items, errors: items.blank? ? [ "A IA local não identificou lançamentos na fatura." ] : [])
  rescue JSON::ParserError
    Result.new(items: [], errors: [ "A IA local retornou uma resposta fora do formato esperado." ])
  rescue Net::ReadTimeout
    Result.new(items: [], errors: [ "A IA local demorou demais para responder. Tente uma imagem menor, um modelo mais leve ou aumente LOCAL_INVOICE_TIMEOUT." ])
  rescue StandardError => error
    Result.new(items: [], errors: [ "Não foi possível analisar a fatura com IA local: #{error.message}" ])
  ensure
    extracted_pdf_text&.close!
    decrypted_file&.close!
    file.rewind if file.respond_to?(:rewind)
  end

  private

  attr_reader :file, :card_id, :due_date, :invoice_password, :categories, :extracted_pdf_text, :decrypted_file

  def request_analysis
    uri = URI(API_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    Net::HTTP.start(uri.hostname, uri.port, read_timeout: request_timeout, open_timeout: 10) do |http|
      http.request(request)
    end
  end

  def payload
    {
      model: DEFAULT_MODEL,
      stream: false,
      format: "json",
      messages: [
        {
          role: "user",
          content: prompt,
          images: image_file? ? [ Base64.strict_encode64(file.read) ] : nil
        }.compact
      ],
      options: {
        temperature: 0
      }
    }
  ensure
    file.rewind if file.respond_to?(:rewind)
  end

  def prompt
    <<~PROMPT
      Você é um extrator local de lançamentos de fatura de cartão.
      Retorne somente JSON válido, sem markdown, no formato:
      {"items":[{"description":"...", "amount":"123,45", "date":"dd/mm/aaaa", "due_date":"", "category_id":"", "payment_method":"credito_a_vista", "card_id":"", "status":"Revisar"}]}

      Regras:
      - Extraia apenas compras à vista, ou seja, transações de compra feitas em estabelecimentos.
      - Ignore compras parceladas, parcelas, pagamentos, pagamento de fatura, boletos, subtotais, totais, cabeçalhos, rodapés, encargos informativos e saldos.
      - Ignore compras parceladas, exemplos: descrição_da_compra parcela x de x, descrição_da_compra parcela x/x
      - Linhas como "PAGAMENTO DE FATURA VIA BOLETO", "Subtotal dos lançamentos", "Total geral dos lançamentos" e "Picpay Card final" não são despesas e não devem aparecer.
      - Use datas no formato dd/mm/aaaa.
      - Use valores no formato brasileiro, sem R$, por exemplo 123,45.
      - payment_method deve ser sempre credito_a_vista.
      - card_id padrão: #{card_id || ""}.
      - due_date padrão: #{due_date || ""}.
      - category_id deve ser escolhido apenas da lista abaixo. Se não houver boa correspondência, deixe vazio.

      Categorias disponíveis:
      #{categories.map { |category| "- #{category.id}: #{category.display_name}" }.join("\n")}

      #{pdf_file? ? "Texto extraído da fatura:\n#{pdf_text}" : "Analise a imagem anexada."}
    PROMPT
  end

  def pdf_text
    @pdf_text ||= begin
      source_path = prepared_pdf_path
      @extracted_pdf_text = Tempfile.new([ "invoice-text", ".txt" ])
      _stdout, stderr, status = Open3.capture3("pdftotext", "-layout", source_path, extracted_pdf_text.path)

      raise missing_pdftotext_message if stderr.include?("No such file") || stderr.include?("not found")
      raise "Não foi possível extrair texto do PDF. #{stderr}".strip unless status.success?

      File.read(extracted_pdf_text.path).to_s.squish
    rescue Errno::ENOENT
      raise missing_pdftotext_message
    end
  end

  def prepared_pdf_path
    return file.tempfile.path if invoice_password.blank?
    raise missing_qpdf_message unless qpdf_available?

    @decrypted_file = Tempfile.new([ "invoice-decrypted", ".pdf" ], binmode: true)
    decrypted_file.close

    _stdout, _stderr, status = Open3.capture3(
      "qpdf",
      "--password=#{invoice_password}",
      "--decrypt",
      file.tempfile.path,
      decrypted_file.path
    )

    raise "Não foi possível abrir a fatura. Verifique a senha informada." unless status.success?

    decrypted_file.path
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

  def extract_message(body)
    body.dig("message", "content").to_s
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

  def ollama_available?
    uri = URI(API_URL)
    Net::HTTP.start(uri.hostname, uri.port, read_timeout: 2) { true }
  rescue Errno::ECONNREFUSED, SocketError
    false
  end

  def qpdf_available?
    system("qpdf", "--version", out: File::NULL, err: File::NULL)
  end

  def missing_qpdf_message
    "Esta fatura exige senha, mas o qpdf não está instalado para desbloquear PDFs protegidos."
  end

  def missing_pdftotext_message
    "Para analisar PDF com IA local, instale o poppler-utils para habilitar o comando pdftotext."
  end

  def api_error(response)
    message = api_error_message(response)
    Result.new(items: [], errors: [ "Erro #{response.code} ao chamar a IA local em #{API_URL}: #{message}" ])
  end

  def request_timeout
    ENV.fetch("LOCAL_INVOICE_TIMEOUT", 420).to_i
  end

  def api_error_message(response)
    message = JSON.parse(response.body).dig("error").presence || "verifique se o modelo #{DEFAULT_MODEL} está disponível no Ollama."

    return "#{message} Rode: ollama pull #{DEFAULT_MODEL}" if message.match?(/model|not found|pull/i)

    message
  rescue JSON::ParserError
    "verifique se o modelo #{DEFAULT_MODEL} está disponível no Ollama."
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
