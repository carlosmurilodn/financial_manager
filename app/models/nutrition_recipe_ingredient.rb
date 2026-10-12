class NutritionRecipeIngredient < ApplicationRecord
  SOURCES = %w[taco custom].freeze
  NUTRIENTS = %i[calories carbohydrates proteins fats].freeze

  belongs_to :nutrition_recipe, inverse_of: :nutrition_recipe_ingredients

  validates :source, inclusion: { in: SOURCES }
  validates :source_id, :name, presence: true
  validates :quantity_grams, numericality: { greater_than: 0, less_than: 100_000_000 }
end
