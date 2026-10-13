module Nutrition
  class MealItemDetails
    def initialize(item)
      @item = item
    end

    def nutrients
      NutritionMealItem::NUTRIENTS.index_with { |field| @item.public_send(field) }.merge(fiber: fiber)
    end

    private

    def fiber
      food = case @item.source
      when "taco" then TacoFood.find_by(id: @item.source_id)
      when "custom" then @item.nutrition_meal.user.custom_foods.find_by(id: @item.source_id)
      end
      food.fiber * @item.quantity_grams / 100 if food&.fiber
    end
  end
end
