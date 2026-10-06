module Health
  class WeeklyComparisonQuery
    def initialize(user:, week_start:, current:)
      @user = user
      @week_start = week_start
      @current = current
    end

    def call
      previous_start = @week_start - 7.days
      weights = @user.weight_entries.where(measured_on: previous_start..(previous_start + 6.days))
      previous_average = weights.average(:weight_kg)&.round(2)
      previous_count = weights.count
      previous_plan = @user.weekly_health_plans.find_by(week_start: previous_start)
      previous_goals = previous_plan ? previous_plan.weekly_health_goals.to_a : []
      previous_wellbeing = @user.weekly_wellbeings.find_by(week_start: previous_start)
      previous_wins = @user.health_wins.where(achieved_on: previous_start..(previous_start + 6.days)).count

      rows = [row("Peso médio", :weight, previous_average, @current[:average_weight]&.round(2)).merge(previous_count: previous_count, current_count: @current[:weight_count])]
      rows.concat(goal_rows(previous_goals, @current[:goals]))
      WeeklyWellbeing::METRICS.each do |attribute, label|
        rows << row(label, :score, previous_wellbeing&.public_send(attribute), @current[:wellbeing]&.public_send(attribute))
      end
      rows << row("Vitórias", :wins, previous_wins.positive? ? previous_wins : nil, @current[:wins_count].positive? ? @current[:wins_count] : nil)
      rows
    end

    private

    def row(label, kind, previous, current)
      { label: label, kind: kind, previous: previous, current: current, delta: previous && current ? current - previous : nil }
    end

    def goal_rows(previous_goals, current_goals)
      normalize = ->(goal) { goal.name.gsub(/[[:space:]]+/, " ").strip.downcase }
      previous_groups = previous_goals.group_by(&normalize)
      current_groups = current_goals.group_by(&normalize)
      keys = current_groups.keys | previous_groups.keys
      return [row("Metas", :goals, nil, nil)] if keys.empty?

      keys.map do |key|
        previous = previous_groups.fetch(key, [])
        current = current_groups.fetch(key, [])
        label = (current.first || previous.first).name
        delta = current.size == 1 && previous.size == 1 ? current.first.completed_count - previous.first.completed_count : nil
        { label: label, kind: :goals, previous: previous.presence, current: current.presence, delta: delta }
      end
    end
  end
end
