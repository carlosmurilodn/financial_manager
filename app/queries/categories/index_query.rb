module Categories
  class IndexQuery
    Result = Struct.new(
      :categories,
      :month_expenses,
      :month_incomes,
      :top_expense_value,
      :uncategorized_value,
      keyword_init: true
    )

    def initialize(user:, description:)
      @user = user
      @description = description
    end

    def call
      current_expenses = user.expenses.where(balance_month: current_month_range)
      current_incomes = user.incomes.where(balance_month: current_month_range)

      Result.new(
        categories: filtered_categories,
        month_expenses: Expense.effective_sum(current_expenses),
        month_incomes: current_incomes.sum(:amount),
        top_expense_value: top_expense_value(current_expenses),
        uncategorized_value: uncategorized_value(current_expenses, current_incomes)
      )
    end

    private

    attr_reader :user, :description

    def filtered_categories
      categories = user.categories.to_a
      return categories.sort_by(&:sort_name) if description.blank?

      normalized_description = normalize_description(description)

      categories
        .select { |category| category.normalized_name.include?(normalized_description) }
        .sort_by(&:sort_name)
    end

    def current_month_range
      Date.current.beginning_of_month..Date.current.end_of_month
    end

    def top_expense_value(current_expenses)
      current_expenses
        .group_by(&:category_id)
        .values
        .map { |expenses| expenses.sum(&:effective_amount).abs }
        .max || 0
    end

    def uncategorized_value(current_expenses, current_incomes)
      Expense.effective_sum(current_expenses.where(category_id: nil)) +
        current_incomes.where(category_id: nil).sum(:amount)
    end

    def normalize_description(value)
      value
        .unicode_normalize(:nfkd)
        .encode("ASCII", replace: "", undef: :replace)
        .downcase
        .gsub(/[^a-z0-9]+/, " ")
        .squeeze(" ")
        .strip
    end
  end
end
