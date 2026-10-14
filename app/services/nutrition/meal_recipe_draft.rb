module Nutrition
  class MealRecipeDraft
    def initialize(meal)
      @meal = meal
    end

    def call
      items = @meal.nutrition_meal_items.to_a
      raise ArgumentError, "Adicione pelo menos um alimento à refeição antes de salvar como receita." if items.empty?
      raise ArgumentError, "Conversão de refeições com receitas aninhadas ainda não é suportada." if items.any? { |item| item.source == "recipe" }
      raise ArgumentError, "Refeições com alimentos TabNut ainda não podem ser convertidas em receitas." if items.any? { |item| item.source == "tabnut" }

      recipe = @meal.user.nutrition_recipes.new(name: @meal.name, final_weight_grams: items.sum(&:quantity_grams), servings: 1)
      items.each do |item|
        ingredient = recipe.nutrition_recipe_ingredients.build(source: item.source, source_id: item.source_id,
          name: item.name, quantity_grams: item.quantity_grams)
        NutritionMealItem::NUTRIENTS.each do |field|
          value = item.public_send(field)
          ingredient.public_send("#{field}=", value * 100 / item.quantity_grams) unless value.nil?
        end
      end
      recipe
    end
  end
end
