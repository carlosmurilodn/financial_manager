module Health
  class PhysicalProgressQuery
    def initialize(user:, week_start:)
      @user = user
      @week_start = week_start
    end

    def call
      dates = (@week_start..@week_start + 6.days).to_a
      consumption = DailyConsumptionQuery.new(user: @user, dates: dates).call
      weights = @user.weight_entries.where("measured_on <= ?", [ dates.last, Date.current ].min).order(:measured_on).to_a
      activities = @user.exercise_entries.includes(:exercise_items).where(performed_on: dates).group_by(&:performed_on)
      profile = @user.health_profile
      rows = dates.map do |date|
        items = activities.fetch(date, []).flat_map { |entry| entry.exercise_items.to_a }
        reference_weight = weights.reverse.find { |entry| entry.measured_on <= date }
        calculation = if date <= Date.current
          DailyCalorieCalculation.new(user: @user, occurred_on: date, consumed_calories: consumption[date][:calories],
            profile: profile, reference_weight: reference_weight, exercise_types: items.map(&:exercise_type).uniq).call
        else
          { bmr: nil, tdee: nil, calorie_deficit: nil }
        end
        {
          date: date, consumed: consumption[date][:calories], source: consumption[date][:source],
          bmr: calculation[:bmr], tdee: calculation[:tdee], deficit: calculation[:calorie_deficit],
          weight: weights.find { |entry| entry.measured_on == date }&.weight_kg,
          reference_weight_date: calculation[:reference_weight_date], activities: items.map(&:type_label).uniq,
          duration: items.filter_map(&:duration_minutes).presence&.sum
        }
      end
      period_weights = weights.select { |entry| dates.include?(entry.measured_on) }
      summary = %i[consumed bmr tdee deficit].index_with do |field|
        values = rows.filter_map { |row| row[field] }
        { mean: values.any? ? values.sum / values.size : nil, total: values.any? ? values.sum : nil, count: values.size }
      end
      summary[:weight_change] = period_weights.size >= 2 ? period_weights.last.weight_kg - period_weights.first.weight_kg : nil
      summary[:weight_count] = period_weights.size
      { days: rows, summary: summary }
    end
  end
end
