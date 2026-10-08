module Health
  class PhysicalWeekQuery
    def initialize(plan:, week_start:)
      @plan = plan
      @week_start = week_start
    end

    def call
      return [] unless @plan&.persisted?

      PhysicalActivities::CATEGORIES.filter_map do |type, label|
        goal = PhysicalActivities.goal_for(@plan, type)
        next unless goal

        records = goal.weekly_health_goal_days.index_by(&:occurred_on)
        days = 7.times.map do |index|
          date = @week_start + index.days
          record = records[date]
          state = if type == "nutrition"
            record&.diet_status.presence || "unselected"
          else
            record&.exercise_day_status.presence || "unselected"
          end
          { date: date, state: state }
        end
        { goal: goal, type: type, label: label, days: days, completed_count: days.count { |day| %w[full completed].include?(day[:state]) } }
      end
    end
  end
end
