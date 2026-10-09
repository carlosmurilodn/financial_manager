module Health
  class PhysicalWeekQuery
    def initialize(user:, plan:, week_start:)
      @user = user
      @plan = plan
      @week_start = week_start
    end

    def call
      rows = []
      goal = @plan&.weekly_health_goals&.find { |record| record.name.parameterize == "alimentacao" }
      if goal&.persisted?
        records = goal.weekly_health_goal_days.index_by(&:occurred_on)
        days = week_dates.map { |date| { date: date, state: records[date]&.diet_status.presence || "unselected" } }
        rows << { goal: goal, type: "nutrition", label: "Alimentação", days: days, completed_count: days.count { |day| day[:state] == "full" } }
      end

      exercise_dates = @user.exercise_entries.joins(:exercise_items)
        .where(performed_on: @week_start..(@week_start + 6.days))
        .distinct.pluck("exercise_items.exercise_type", :performed_on)
        .group_by(&:first)
      ExerciseItem::TYPES.each do |type, label|
        dates = exercise_dates.fetch(type, []).map(&:last)
        next if dates.empty?

        days = week_dates.map { |date| { date: date, state: dates.include?(date) ? "completed" : "unselected" } }
        rows << { goal: nil, type: type, label: label, days: days, completed_count: dates.uniq.size }
      end
      rows
    end

    private

    def week_dates
      (@week_start..(@week_start + 6.days)).to_a
    end
  end
end
