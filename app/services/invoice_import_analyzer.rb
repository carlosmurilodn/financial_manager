require "csv"

class InvoiceImportAnalyzer
  SUPPORTED_TEXT_TYPES = %w[text/csv text/plain application/csv].freeze
  SUPPORTED_EXTENSIONS = %w[.csv .txt].freeze

  Result = Struct.new(:items, :errors, keyword_init: true)

  def initialize(file:, card_id:, due_date:, invoice_password: nil, categories:)
    @file = file
    @card_id = card_id.presence
    @due_date = due_date.presence
    @invoice_password = invoice_password.presence
    @categories = categories
  end

  def call
    return Result.new(items: [], errors: [ "Selecione uma fatura para analisar." ]) if file.blank?
    return ai_result unless text_file?

    items = csv_items
    items = text_items if items.blank?

    Result.new(items: items, errors: items.blank? ? [ "Nenhum lançamento foi identificado no arquivo." ] : [])
  rescue CSV::MalformedCSVError
    Result.new(items: text_items, errors: [])
  rescue StandardError => error
    Result.new(items: [], errors: [ "Não foi possível analisar o arquivo: #{error.message}" ])
  end

  private

  attr_reader :file, :card_id, :due_date, :invoice_password, :categories

  def ai_result
    ai_analyzer_class.new(
      file: file,
      card_id: card_id,
      due_date: due_date,
      invoice_password: invoice_password,
      categories: categories
    ).call
  end

  def ai_analyzer_class
    ENV.fetch("INVOICE_AI_PROVIDER", "local") == "openai" ? OpenaiInvoiceAnalyzer : LocalInvoiceAnalyzer
  end

  def text_file?
    SUPPORTED_TEXT_TYPES.include?(file.content_type) || SUPPORTED_EXTENSIONS.include?(File.extname(file.original_filename).downcase)
  end

  def content
    @content ||= file.read.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
  ensure
    file.rewind if file.respond_to?(:rewind)
  end

  def csv_items
    rows = CSV.parse(content, headers: true, col_sep: detected_separator)
    return [] if rows.headers.blank?

    rows.filter_map do |row|
      description = first_present(row, "descricao", "descrição", "description", "historico", "histórico", "estabelecimento", "lancamento", "lançamento")
      amount = first_present(row, "valor", "amount", "preco", "preço")
      date = first_present(row, "data", "date", "compra", "purchase_date")

      build_item(description:, amount:, date:)
    end
  end

  def text_items
    content.lines.filter_map do |line|
      date = line.match(%r{\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b})&.to_s
      amount = line.match(/-?(?:R\$\s*)?\d{1,3}(?:\.\d{3})*,\d{2}/)&.to_s
      next if date.blank? || amount.blank?

      description = line.sub(date, "").sub(amount, "").squish
      build_item(description:, amount:, date:)
    end
  end

  def build_item(description:, amount:, date:)
    description = description.to_s.squish
    amount = amount.to_s.squish
    date = date.to_s.squish
    return if ignored_entry?(description)
    return if description.blank? || amount.blank?

    category = suggested_category(description)

    {
      description: description,
      amount: amount,
      date: date,
      due_date: due_date,
      category_id: category&.id,
      payment_method: "credito_a_vista",
      card_id: card_id,
      status: "Revisar"
    }
  end

  def first_present(row, *names)
    normalized_headers = row.headers.index_by { |header| normalize(header) }
    header = names.map { |name| normalized_headers[normalize(name)] }.compact.first
    row[header].presence if header
  end

  def suggested_category(description)
    categories.find do |category|
      description.downcase.include?(category.clean_name.downcase)
    end
  end

  def detected_separator
    content.lines.first.to_s.count(";") > content.lines.first.to_s.count(",") ? ";" : ","
  end

  def normalize(value)
    value.to_s.parameterize(separator: "_")
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
      "boleto"
    ]
  end
end
