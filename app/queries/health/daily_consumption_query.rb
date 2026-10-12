module Health
  class DailyConsumptionQuery
    def initialize(user:, dates:)
      @user = user
      @dates = dates.to_a
    end

    def call
      meals = @user.nutrition_meals.includes(:nutrition_meal_items).where(occurred_on: @dates).group_by(&:occurred_on)
      @dates.index_with do |date|
        items = meals.fetch(date, []).flat_map { |meal| meal.nutrition_meal_items.to_a }
        if items.any?
          { calories: Nutrition::MealSummary.totals(items)[:calories], source: :meals }
        else
          { calories: nil, source: :none }
        end
      end
    end
  end
end
