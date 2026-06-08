module Expenses
  class IndexQuery
    Result = Struct.new(
      :expenses,
      :total_amount,
      :total_paid,
      :total_unpaid,
      :previous_balance,
      :net_balance,
      keyword_init: true
    )

    def initialize(user:, filters:)
      @user = user
      @filters = filters
    end

    def call
      expenses = filtered_expenses
      totals = totals_for(expenses)

      Result.new(
        expenses: expenses,
        total_amount: totals[:amount],
        total_paid: totals[:paid],
        total_unpaid: totals[:unpaid],
        previous_balance: previous_balance,
        net_balance: net_balance
      )
    end

    private

    attr_reader :user, :filters

    def filtered_expenses
      expanded_expenses
        .then { |expenses| filter_by_month(expenses) }
        .then { |expenses| filter_by_category(expenses) }
        .then { |expenses| filter_by_payment_method(expenses) }
        .then { |expenses| filter_by_card(expenses) }
        .then { |expenses| filter_by_paid(expenses) }
        .then { |expenses| filter_by_description(expenses) }
    end

    def expanded_expenses
      user.expenses
          .includes(:category, :card)
          .order(balance_month: :desc, date: :asc, current_installment: :asc)
          .to_a
    end

    def filter_by_month(expenses)
      return expenses if month.blank? || year.blank?

      expenses.select do |expense|
        expense.balance_month.month == month && expense.balance_month.year == year
      end
    end

    def filter_by_category(expenses)
      return expenses if category_id.blank?

      expenses.select { |expense| expense.category_id.to_s == category_id.to_s }
    end

    def filter_by_payment_method(expenses)
      return expenses if payment_method.blank?

      expenses.select { |expense| expense.payment_method == payment_method }
    end

    def filter_by_card(expenses)
      return expenses if card_id.blank?

      expenses.select { |expense| expense.card_id.to_s == card_id.to_s }
    end

    def filter_by_paid(expenses)
      return expenses if paid.blank?

      paid_value = ActiveModel::Type::Boolean.new.cast(paid)
      expenses.select { |expense| expense.paid == paid_value }
    end

    def filter_by_description(expenses)
      return expenses if description.blank?

      expenses.select do |expense|
        expense.description.to_s.downcase.include?(description.downcase)
      end
    end

    def totals_for(expenses)
      {
        amount: expenses.sum(&:effective_amount),
        paid: expenses.select(&:paid?).sum(&:effective_amount),
        unpaid: expenses.reject(&:paid?).sum(&:effective_amount)
      }
    end

    def previous_balance
      return unless complete_period_filter?

      incomes_before_selected_month - expenses_before_selected_month
    end

    def net_balance
      return unless complete_period_filter?

      paid_incomes_until_selected_month - paid_expenses_until_selected_month
    end

    def incomes_before_selected_month
      user.incomes.where("balance_month <= ?", previous_month_end).sum(:amount)
    end

    def expenses_before_selected_month
      Expense.effective_sum(user.expenses.where("balance_month <= ?", previous_month_end))
    end

    def paid_incomes_until_selected_month
      user.incomes.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)
    end

    def paid_expenses_until_selected_month
      Expense.effective_sum(user.expenses.where("balance_month <= ? AND paid = ?", current_month_end, true))
    end

    def previous_month_end
      current_month_start - 1.day
    end

    def current_month_end
      current_month_start.end_of_month
    end

    def current_month_start
      Date.new(year, month, 1)
    end

    def complete_period_filter?
      month.present? && year.present?
    end

    def description
      filters[:description]
    end

    def month
      filters[:month]
    end

    def year
      filters[:year]
    end

    def category_id
      filters[:category_id]
    end

    def payment_method
      filters[:payment_method]
    end

    def card_id
      filters[:card_id]
    end

    def paid
      filters[:paid]
    end
  end
end
