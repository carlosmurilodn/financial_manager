module Health
  class WeeklyNutritionSummaryQuery
    attr_reader :period_summary

    def initialize(user:, weeks:)
      @user = user
      @weeks = weeks
    end

    def call
      dates = @weeks.flat_map { |week| (week..week + 6.days).to_a }
      meals = @user.nutrition_meals.includes(:nutrition_meal_items).where(occurred_on: dates).to_a
      meals_by_date = meals.group_by(&:occurred_on)
      daily_totals = meals_by_date.filter_map do |date, records|
        items = records.flat_map { |meal| meal.nutrition_meal_items.to_a }
        [date, Nutrition::MealSummary.totals(items)] if items.any?
      end.to_h
      @period_summary = summarize(daily_totals.values).merge(meals_count: meals.size)
      @weeks.index_with do |week|
        days = (week..week + 6.days).filter_map { |date| daily_totals[date] }
        meals_count = (week..week + 6.days).sum { |date| meals_by_date.fetch(date, []).size }
        summarize(days).merge(meals_count: meals_count)
      end
    end

    private

    def summarize(days)
      metrics = NutritionMealItem::NUTRIENTS.index_with do |field|
        values = days.filter_map { |day| day[field] }
        { mean: values.any? ? values.sum / values.size : nil, count: values.size }
      end
      metrics.merge(consumed: metrics[:calories], registered_days: days.size)
    end
  end
end
