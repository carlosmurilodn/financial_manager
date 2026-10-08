module Health
  class WeeklyCalorieSummaryQuery
    def initialize(user:, weeks:)
      @user = user
      @weeks = weeks
    end

    def call
      dates = @weeks.flat_map { |week| (week..week + 6.days).to_a }
      records = @user.daily_calorie_entries.where(occurred_on: dates)
        .pluck(:occurred_on, :consumed_calories, :tdee, :calorie_deficit)
        .group_by { |record| record.first.beginning_of_week(:monday) }

      @weeks.index_with do |week|
        days = records.fetch(week, [])
        { consumed: average(days, 1), expenditure: average(days, 2), deficit: average(days, 3) }
      end
    end

    private

    def average(days, column)
      values = days.filter_map { |record| record[column] }
      { mean: values.any? ? values.sum / values.size : nil, count: values.size }
    end
  end
end
