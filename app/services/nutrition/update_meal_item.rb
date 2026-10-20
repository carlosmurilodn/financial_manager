module Nutrition
  class UpdateMealItem
    def initialize(meal:, item_id:, quantity_grams:, destination_meal_id: nil)
      @meal = meal
      @destination_meal_id = destination_meal_id.presence || meal.id
      @item_id = item_id
      @quantity = BigDecimal(quantity_grams.to_s)
    rescue ArgumentError
      raise ArgumentError, "Informe uma quantidade válida."
    end

    def call
      unless @quantity.finite? && @quantity.positive? && @quantity < 100_000_000 && @quantity == @quantity.round(4)
        raise ArgumentError, "Informe uma quantidade positiva com até quatro casas decimais."
      end

      destination = @meal.user.nutrition_meals.where(occurred_on: @meal.occurred_on).find_by(id: @destination_meal_id)
      raise ArgumentError, "Selecione uma refeição deste dia." unless destination

      NutritionMeal.transaction do
        @meal.user.nutrition_meals.where(id: [@meal.id, destination.id]).order(:id).lock.load
        item = @meal.nutrition_meal_items.find(@item_id)
        ratio = @quantity / item.quantity_grams
        NutritionMealItem::NUTRIENTS.each do |field|
          value = item.public_send(field)
          item.public_send("#{field}=", value * ratio) unless value.nil?
        end
        item.quantity_grams = @quantity
        if destination.id != @meal.id
          existing = destination.nutrition_meal_items.find_by(source: item.source, source_id: item.source_id)
          if existing
            if item.source == "tabnut" && !existing.same_tabnut_composition?(item)
              raise ArgumentError, "O alimento TabNut no destino possui dados diferentes. Selecione outra refeição."
            end
            existing.quantity_grams += item.quantity_grams
            NutritionMealItem::NUTRIENTS.each do |field|
              stored = existing.public_send(field)
              value = item.public_send(field)
              existing.public_send("#{field}=", stored && value ? stored + value : nil)
            end
            existing.addition_tokens = (existing.addition_tokens + item.addition_tokens).uniq
            existing.last_added_at = [existing.last_added_at || existing.created_at, item.last_added_at || item.created_at].max
            existing.save!
            item.destroy!
            next existing
          end
          item.nutrition_meal = destination
        end
        item.save!
        item
      end
    end
  end
end
