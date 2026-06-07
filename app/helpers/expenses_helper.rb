module ExpensesHelper
  EXPENSE_SORT_OPTIONS = {
    "description_asc" => { label: "Descrição Crescente", sort: "description", direction: "asc" },
    "description_desc" => { label: "Descrição Decrescente", sort: "description", direction: "desc" },
    "amount_desc" => { label: "Maior Valor", sort: "amount", direction: "desc" },
    "amount_asc" => { label: "Menor Valor", sort: "amount", direction: "asc" },
    "date_desc" => { label: "Vencimento Recente", sort: "date", direction: "desc" },
    "date_asc" => { label: "Vencimento Futuro", sort: "date", direction: "asc" },
    "created_at_desc" => { label: "Criação Recente", sort: "created_at", direction: "desc" },
    "created_at_asc" => { label: "Criação Remota", sort: "created_at", direction: "asc" },
    "category_asc" => { label: "Categoria Crescente", sort: "category", direction: "asc" },
    "category_desc" => { label: "Categoria Descrescente", sort: "category", direction: "desc" }
  }.freeze
  DEFAULT_EXPENSE_SORT_OPTION = "date_desc"

  def default_expense_sort_option
    DEFAULT_EXPENSE_SORT_OPTION
  end

  def expense_sort_options
    EXPENSE_SORT_OPTIONS.map { |value, config| [ config[:label], value ] }
  end
end
