module Nutrition
  class SaveRecipe
    def initialize(recipe)
      @recipe = recipe
    end

    def call
      unavailable = []
      @recipe.nutrition_recipe_ingredients.reject(&:marked_for_destruction?).each do |ingredient|
        # Keep existing snapshots when only quantities or recipe details change.
        next if ingredient.persisted? && !ingredient.source_changed? && !ingredient.source_id_changed?

        food = case ingredient.source
        when "taco" then TacoFood.find_by(id: ingredient.source_id)
        when "custom" then @recipe.user.custom_foods.find_by(id: ingredient.source_id)
        end
        if food
          ingredient.source_id = food.id.to_s
          ingredient.name = food.name
          NutritionRecipeIngredient::NUTRIENTS.each { |field| ingredient.public_send("#{field}=", food.public_send(field)) }
        else
          unavailable << ingredient
        end
      end

      valid = @recipe.valid?
      unavailable.each { |ingredient| ingredient.errors.add(:source_id, "não está disponível para este usuário") }
      @recipe.errors.add(:base, "Selecione alimentos disponíveis da TACO ou dos seus alimentos.") if unavailable.any?
      return false unless valid && unavailable.empty?

      @recipe.save
    end
  end
end
