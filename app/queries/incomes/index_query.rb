module Incomes
  class IndexQuery
    Result = Struct.new(
      :incomes,
      :total_amount,
      :total_received,
      :total_pending,
      :previous_balance,
      :current_balance,
      keyword_init: true
    )

    def initialize(user:, filters:)
      @user = user
      @filters = filters
    end

    def call
      incomes = filtered_incomes

      Result.new(
        incomes: incomes,
        total_amount: incomes.sum(&:amount),
        total_received: incomes.select(&:paid?).sum(&:amount),
        total_pending: incomes.reject(&:paid?).sum(&:amount),
        previous_balance: previous_balance,
        current_balance: current_balance
      )
    end

    private

    attr_reader :user, :filters

    def filtered_incomes
      base_incomes
        .then { |incomes| filter_by_month(incomes) }
        .then { |incomes| filter_by_description(incomes) }
        .then { |incomes| filter_by_paid(incomes) }
        .then { |incomes| filter_by_category(incomes) }
        .then { |incomes| filter_by_amount_min(incomes) }
        .then { |incomes| filter_by_amount_max(incomes) }
    end

    def base_incomes
      user.incomes.includes(:category).order(balance_month: :asc, date: :asc).to_a
    end

    def filter_by_month(incomes)
      return incomes if month.blank? || year.blank?

      incomes.select { |income| income.balance_month.month == month && income.balance_month.year == year }
    end

    def filter_by_description(incomes)
      return incomes if description.blank?

      incomes.select { |income| income.description.to_s.downcase.include?(description.downcase) }
    end

    def filter_by_paid(incomes)
      return incomes if paid.blank?

      paid_value = ActiveModel::Type::Boolean.new.cast(paid)
      incomes.select { |income| income.paid == paid_value }
    end

    def filter_by_category(incomes)
      return incomes if category_id.blank?

      incomes.select { |income| income.category_id.to_s == category_id.to_s }
    end

    def filter_by_amount_min(incomes)
      return incomes if amount_min.blank?

      minimum = parse_amount(amount_min)
      return incomes if minimum.nil? || minimum.zero?

      incomes.select { |income| income.amount.to_d >= minimum }
    end

    def filter_by_amount_max(incomes)
      return incomes if amount_max.blank?

      maximum = parse_amount(amount_max)
      return incomes if maximum.nil? || maximum.zero?

      incomes.select { |income| income.amount.to_d <= maximum }
    end

    def parse_amount(value)
      return nil if value.blank?

      cleaned = value.to_s.gsub(/[^\d,\.]/, "")
      return nil if cleaned.blank?

      normalized = if cleaned.include?(",")
        cleaned.delete(".").tr(",", ".")
      else
        cleaned
      end

      BigDecimal(normalized)
    rescue ArgumentError
      nil
    end

    def previous_balance
      return 0 unless complete_period_filter?

      incomes_before_selected_month - expenses_before_selected_month
    end

    def current_balance
      return 0 unless complete_period_filter?

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

    def month = filters[:month]
    def year = filters[:year]
    def description = filters[:description]
    def paid = filters[:paid]
    def category_id = filters[:category_id]
    def amount_min = filters[:amount_min]
    def amount_max = filters[:amount_max]
  end
end
