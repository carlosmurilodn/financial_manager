module Health
  class PhysicalWeekQuery
    def initialize(user:, plan:, week_start:, physical_progress: nil)
      @user = user
      @plan = plan
      @week_start = week_start
      @physical_progress = physical_progress
    end

    def call
      rows = []
      goal = @plan&.weekly_health_goals&.find { |record| record.name.parameterize == "alimentacao" }
      progress = @physical_progress || PhysicalProgressQuery.new(user: @user, week_start: @week_start).call
      if goal&.persisted? || progress[:days].any? { |day| day[:source] == :meals }
        days = progress[:days].map { |day| { date: day[:date], state: nutrition_state(day) } }
        rows << { goal: goal, type: "nutrition", label: "Alimentação", days: days, completed_count: days.count { |day| day[:state] == "deficit" } }
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

    def nutrition_state(day)
      return "unselected" unless day[:source] == :meals
      return "pending" if day[:deficit].nil?
      return "deficit" if day[:deficit].positive?
      return "surplus" if day[:deficit].negative?

      "balanced"
    end

    def week_dates
      (@week_start..(@week_start + 6.days)).to_a
    end
  end
end
