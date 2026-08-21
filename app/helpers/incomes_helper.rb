module IncomesHelper
  INCOME_SORT_OPTIONS = {
    "balance_month_desc" => { label: "Competência Recente", sort: "balance_month", direction: "desc" },
    "balance_month_asc" => { label: "Competência Antiga", sort: "balance_month", direction: "asc" },
    "description_asc" => { label: "Descrição Crescente", sort: "description", direction: "asc" },
    "description_desc" => { label: "Descrição Decrescente", sort: "description", direction: "desc" },
    "amount_desc" => { label: "Maior Valor", sort: "amount", direction: "desc" },
    "amount_asc" => { label: "Menor Valor", sort: "amount", direction: "asc" },
    "date_desc" => { label: "Data Recente", sort: "date", direction: "desc" },
    "date_asc" => { label: "Data Antiga", sort: "date", direction: "asc" },
    "category_asc" => { label: "Categoria Crescente", sort: "category", direction: "asc" },
    "category_desc" => { label: "Categoria Decrescente", sort: "category", direction: "desc" },
    "paid_desc" => { label: "Recebidas Primeiro", sort: "paid", direction: "desc" },
    "paid_asc" => { label: "Pendentes Primeiro", sort: "paid", direction: "asc" }
  }.freeze
  DEFAULT_INCOME_SORT_OPTION = "balance_month_asc"

  def default_income_sort_option
    DEFAULT_INCOME_SORT_OPTION
  end

  def income_sort_options
    INCOME_SORT_OPTIONS.map { |value, config| [config[:label], value] }
  end
end
