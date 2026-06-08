module FinancialGoals
  class IndexQuery
    Result = Struct.new(
      :goals,
      :count,
      :active_count,
      :target_total,
      :current_total,
      :nearest_due_date,
      keyword_init: true
    )

    def initialize(user:, filters:)
      @user = user
      @filters = filters
    end

    def call
      goals = filtered_goals

      Result.new(
        goals: goals,
        count: goals.size,
        active_count: goals.count { |goal| goal.status_planned? || goal.status_in_progress? },
        target_total: goals.sum { |goal| goal.target_amount.to_d },
        current_total: goals.sum(&:progress_amount),
        nearest_due_date: goals.reject(&:status_completed?).map(&:due_date).compact.min
      )
    end

    private

    attr_reader :user, :filters

    def filtered_goals
      base_goals
        .then { |goals| filter_by_description(goals) }
        .then { |goals| filter_by_category(goals) }
        .then { |goals| filter_by_progress(goals) }
        .then { |goals| filter_by_current_amount(goals) }
        .then { |goals| filter_by_target_amount(goals) }
        .then { |goals| filter_by_credit_amount(goals) }
        .then { |goals| filter_by_potential_amount(goals) }
        .then { |goals| filter_by_remaining_amount(goals) }
        .then { |goals| filter_by_monthly_amount(goals) }
        .then { |goals| filter_by_due_until(goals) }
        .then { |goals| filter_by_status(goals) }
        .then { |goals| filter_by_priority(goals) }
    end

    def base_goals
      user.financial_goals.includes(:category, :financial_goal_resources).to_a
    end

    def filter_by_description(goals)
      return goals if description.blank?

      goals.select { |goal| goal.description.to_s.downcase.include?(description.downcase) }
    end

    def filter_by_category(goals)
      return goals if category_id.blank?

      goals.select { |goal| goal.category_id.to_s == category_id.to_s }
    end

    def filter_by_progress(goals)
      return goals if progress_min.blank?

      goals.select { |goal| goal.progress_percent >= progress_min.to_f }
    end

    def filter_by_current_amount(goals)
      return goals if current_amount_min.blank?

      minimum = parse_brazilian_amount(current_amount_min, blank: 0)
      goals.select { |goal| goal.progress_amount >= minimum }
    end

    def filter_by_target_amount(goals)
      return goals if target_amount_min.blank?

      minimum = parse_brazilian_amount(target_amount_min, blank: 0)
      goals.select { |goal| goal.target_amount.to_d >= minimum }
    end

    def filter_by_credit_amount(goals)
      return goals if credit_amount_min.blank?

      minimum = parse_brazilian_amount(credit_amount_min, blank: 0)
      goals.select { |goal| goal.credit_limit_amount >= minimum }
    end

    def filter_by_potential_amount(goals)
      return goals if potential_amount_min.blank?

      minimum = parse_brazilian_amount(potential_amount_min, blank: 0)
      goals.select { |goal| goal.potential_amount >= minimum }
    end

    def filter_by_remaining_amount(goals)
      return goals if remaining_amount_max.blank?

      maximum = parse_brazilian_amount(remaining_amount_max, blank: 0)
      goals.select { |goal| goal.remaining_amount <= maximum }
    end

    def filter_by_monthly_amount(goals)
      return goals if monthly_amount_max.blank?

      maximum = parse_brazilian_amount(monthly_amount_max, blank: 0)
      goals.select { |goal| goal.monthly_required_amount <= maximum }
    end

    def filter_by_due_until(goals)
      due_until_date = parse_goal_date(due_until)
      return goals if due_until_date.blank?

      goals.select { |goal| goal.due_date.present? && goal.due_date <= due_until_date }
    end

    def filter_by_status(goals)
      return goals if status.blank?

      goals.select { |goal| goal.status == status }
    end

    def filter_by_priority(goals)
      return goals if priority.blank?

      goals.select { |goal| goal.priority == priority }
    end

    def parse_brazilian_amount(value, blank: nil)
      return blank if value.blank?

      cleaned = value.to_s.gsub(/[^\d,\.]/, "")
      return blank if cleaned.blank?

      normalized = if cleaned.include?(",")
        cleaned.delete(".").tr(",", ".")
      else
        cleaned.delete(".")
      end

      BigDecimal(normalized)
    rescue ArgumentError
      blank
    end

    def parse_goal_date(value)
      return if value.blank?

      Date.iso8601(value)
    rescue ArgumentError, TypeError
      Date.strptime(value, "%d/%m/%Y")
    rescue ArgumentError, TypeError
      nil
    end

    def description = filters[:description]
    def category_id = filters[:category_id]
    def progress_min = filters[:progress_min]
    def current_amount_min = filters[:current_amount_min]
    def target_amount_min = filters[:target_amount_min]
    def credit_amount_min = filters[:credit_amount_min]
    def potential_amount_min = filters[:potential_amount_min]
    def remaining_amount_max = filters[:remaining_amount_max]
    def monthly_amount_max = filters[:monthly_amount_max]
    def due_until = filters[:due_until]
    def status = filters[:status]
    def priority = filters[:priority]
  end
end
