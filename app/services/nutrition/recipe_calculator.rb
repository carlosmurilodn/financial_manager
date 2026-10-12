module Nutrition
  class RecipeCalculator
    def initialize(recipe)
      @recipe = recipe
    end

    def ingredient_totals(ingredient)
      NutritionRecipeIngredient::NUTRIENTS.index_with do |field|
        value = ingredient.public_send(field)
        value.to_d * ingredient.quantity_grams / 100 if value && ingredient.quantity_grams&.positive?
      end
    end

    def totals
      ingredients = @recipe.nutrition_recipe_ingredients.reject(&:marked_for_destruction?)
      values = ingredients.map { |ingredient| ingredient_totals(ingredient) }
      whole = NutritionRecipeIngredient::NUTRIENTS.index_with do |field|
        amounts = values.map { |value| value[field] }
        amounts.sum if amounts.any? && amounts.none?(&:nil?)
      end
      {
        whole: whole,
        per_100g: whole.transform_values { |value| value * 100 / @recipe.final_weight_grams if value && @recipe.final_weight_grams&.positive? },
        per_serving: whole.transform_values { |value| value / @recipe.servings if value && @recipe.servings&.positive? }
      }
    end
  end
end
