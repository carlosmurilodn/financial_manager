module Categories
  class IndexQuery
    Result = Struct.new(
      :categories,
      :sort_option,
      :month_expenses,
      :month_incomes,
      :top_expense_value,
      :uncategorized_value,
      :expenses_by_category,
      :incomes_by_category,
      keyword_init: true
    )

    SORT_OPTIONS = %w[name_asc expense_desc expense_asc].freeze
    DEFAULT_SORT_OPTION = "name_asc"

    def initialize(user:, description:, month: nil, year: nil, sort_option: nil)
      @user = user
      @description = description
      @month = month
      @year = year
      @sort_option = SORT_OPTIONS.include?(sort_option) ? sort_option : DEFAULT_SORT_OPTION
    end

    def call
      current_expenses = user.expenses.where(balance_month: month_range)
      current_incomes = user.incomes.where(balance_month: month_range)
      expenses_by_category = expenses_grouped_by_category(current_expenses)

      Result.new(
        categories: filtered_categories(expenses_by_category),
        sort_option: sort_option,
        month_expenses: Expense.effective_sum(current_expenses),
        month_incomes: current_incomes.sum(:amount),
        top_expense_value: top_expense_value(current_expenses),
        uncategorized_value: uncategorized_value(current_expenses, current_incomes),
        expenses_by_category: expenses_by_category,
        incomes_by_category: incomes_grouped_by_category(current_incomes)
      )
    end

    private

    attr_reader :user, :description, :month, :year, :sort_option

    def filtered_categories(expenses_by_category)
      categories = user.categories.to_a
      if description.present?
        normalized_description = normalize_description(description)
        categories.select! { |category| category.normalized_name.include?(normalized_description) }
      end

      sort_categories(categories, expenses_by_category)
    end

    def sort_categories(categories, expenses_by_category)
      categories.sort_by do |category|
        expense_total = expenses_by_category.fetch(category.id, 0)

        case sort_option
        when "expense_desc"
          [ -expense_total, category.sort_name ]
        when "expense_asc"
          [ expense_total, category.sort_name ]
        else
          [ category.sort_name ]
        end
      end
    end

    def month_range
      ref_date = Date.new(year || Date.current.year, month || Date.current.month, 1)
      ref_date.beginning_of_month..ref_date.end_of_month
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

    def expenses_grouped_by_category(current_expenses)
      current_expenses.group(:category_id).sum(:amount).transform_values(&:to_f)
    end

    def incomes_grouped_by_category(current_incomes)
      current_incomes.group(:category_id).sum(:amount).transform_values(&:to_f)
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
