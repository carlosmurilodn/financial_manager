module Health
  class DailyConsumptionQuery
    def initialize(user:, dates:)
      @user = user
      @dates = dates.to_a
    end

    def call
      meals = @user.nutrition_meals.includes(:nutrition_meal_items).where(occurred_on: @dates).group_by(&:occurred_on)
      legacy = @user.daily_calorie_entries.where(occurred_on: @dates).pluck(:occurred_on, :consumed_calories).to_h
      @dates.index_with do |date|
        items = meals.fetch(date, []).flat_map { |meal| meal.nutrition_meal_items.to_a }
        if items.any?
          { calories: Nutrition::MealSummary.totals(items)[:calories], source: :meals }
        elsif legacy[date].nil?
          { calories: nil, source: :none }
        else
          { calories: legacy[date], source: :legacy }
        end
      end
    end
  end
end
