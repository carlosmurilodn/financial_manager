module Health
  class WeeklyPlan
    DEFAULT_GOALS = [
      { name: "Alimentação", target_count: 7, notes: "Dias com alimentação planejada, incluindo marmitas, lanches e outras refeições." }
    ].map(&:freeze).freeze

    def self.week_start(value)
      date = value.present? ? Date.iso8601(value.to_s) : Date.current
      date.beginning_of_week(:monday)
    rescue ArgumentError
      Date.current.beginning_of_week(:monday)
    end

    def self.build(user:, week_start:)
      plan = user.weekly_health_plans.find_by(week_start: week_start)
      return plan if plan

      previous_plan = user.weekly_health_plans.where("week_start < ?", week_start).order(week_start: :desc).first
      goals = if previous_plan
        previous_plan.weekly_health_goals.order(:id)
          .reject { |goal| WeeklyHealthGoal::LEGACY_EXERCISE_NAMES.include?(goal.name.parameterize) }
          .map { |goal| goal.attributes.slice("name", "target_count", "notes") }
      else
        DEFAULT_GOALS
      end

      goals = DEFAULT_GOALS if goals.empty?

      plan = user.weekly_health_plans.new(week_start: week_start)
      goals.each { |attributes| plan.weekly_health_goals.build(attributes.merge(completed_count: 0)) }
      plan
    end
  end
end
