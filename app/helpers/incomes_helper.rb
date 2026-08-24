module IncomesHelper
  INCOME_SORT_OPTIONS = {
    "created_at_desc" => { label: "Criação Recente", sort: "created_at", direction: "desc" },
    "created_at_asc" => { label: "Criação Antiga", sort: "created_at", direction: "asc" },
    "amount_desc" => { label: "Maior Valor", sort: "amount", direction: "desc" },
    "amount_asc" => { label: "Menor Valor", sort: "amount", direction: "asc" },
    "date_desc" => { label: "Data Recente", sort: "date", direction: "desc" },
    "date_asc" => { label: "Data Antiga", sort: "date", direction: "asc" }
  }.freeze
  DEFAULT_INCOME_SORT_OPTION = "created_at_desc"

  def default_income_sort_option
    DEFAULT_INCOME_SORT_OPTION
  end

  def income_sort_options
    INCOME_SORT_OPTIONS.map { |value, config| [config[:label], value] }
  end
end
