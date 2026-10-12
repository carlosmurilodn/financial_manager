module Nutrition
  class UpdateMealItem
    def initialize(meal:, item_id:, quantity_grams:)
      @meal = meal
      @item_id = item_id
      @quantity = BigDecimal(quantity_grams.to_s)
    rescue ArgumentError
      raise ArgumentError, "Informe uma quantidade válida em gramas."
    end

    def call
      unless @quantity.finite? && @quantity.positive? && @quantity < 100_000_000 && @quantity == @quantity.round(4)
        raise ArgumentError, "Informe uma quantidade positiva com até quatro casas decimais."
      end

      @meal.with_lock do
        item = @meal.nutrition_meal_items.find(@item_id)
        ratio = @quantity / item.quantity_grams
        NutritionMealItem::NUTRIENTS.each do |field|
          value = item.public_send(field)
          item.public_send("#{field}=", value * ratio) unless value.nil?
        end
        item.quantity_grams = @quantity
        item.save!
        item
      end
    end
  end
end
