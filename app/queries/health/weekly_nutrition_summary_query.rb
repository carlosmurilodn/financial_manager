module Health
  class WeeklyNutritionSummaryQuery
    def initialize(user:, weeks:)
      @user = user
      @weeks = weeks
    end

    def call
      consumption = DailyConsumptionQuery.new(user: @user, dates: @weeks.flat_map { |week| (week..week + 6.days).to_a }).call
      @weeks.index_with do |week|
        values = (week..week + 6.days).filter_map { |date| consumption[date][:calories] }
        { consumed: { mean: values.any? ? values.sum / values.size : nil, count: values.size } }
      end
    end
  end
end
