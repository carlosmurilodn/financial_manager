class NutritionMealItem < ApplicationRecord
  SOURCES = %w[taco custom recipe].freeze

  belongs_to :nutrition_meal, inverse_of: :nutrition_meal_items

  validates :source, inclusion: { in: SOURCES }
  validates :source_id, :name, presence: true
  validates :quantity_grams, numericality: { greater_than: 0, less_than: 100_000_000 }
  validates :calories, :carbohydrates, :proteins, :fats,
            numericality: { greater_than_or_equal_to: 0, less_than: 100_000_000 }
end
