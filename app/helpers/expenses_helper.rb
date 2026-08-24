module ExpensesHelper
  EXPENSE_SORT_OPTIONS = {
    "created_at_desc" => { label: "Criação Recente", sort: "created_at", direction: "desc" },
    "created_at_asc" => { label: "Criação Antiga", sort: "created_at", direction: "asc" },
    "amount_desc" => { label: "Maior Valor", sort: "amount", direction: "desc" },
    "amount_asc" => { label: "Menor Valor", sort: "amount", direction: "asc" },
    "date_desc" => { label: "Vencimento Recente", sort: "date", direction: "desc" },
    "date_asc" => { label: "Vencimento Futuro", sort: "date", direction: "asc" }
  }.freeze
  DEFAULT_EXPENSE_SORT_OPTION = "created_at_desc"

  def default_expense_sort_option
    DEFAULT_EXPENSE_SORT_OPTION
  end

  def expense_sort_options
    EXPENSE_SORT_OPTIONS.map { |value, config| [ config[:label], value ] }
  end
end
