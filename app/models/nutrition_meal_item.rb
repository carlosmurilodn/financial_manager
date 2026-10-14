class NutritionMealItem < ApplicationRecord
  SOURCES = %w[taco custom recipe tabnut].freeze
  NUTRIENTS = %i[calories carbohydrates proteins fats].freeze

  belongs_to :nutrition_meal, inverse_of: :nutrition_meal_items

  validates :source, inclusion: { in: SOURCES }
  validates :source_id, :name, presence: true
  validates :quantity_grams, numericality: { greater_than: 0, less_than: 100_000_000 }
  validates :calories, :carbohydrates, :proteins, :fats,
            numericality: { greater_than_or_equal_to: 0, less_than: 100_000_000 }, allow_nil: true
  validates :food_snapshot, presence: true, if: -> { source == "tabnut" }

  def same_tabnut_composition?(other)
    %w[serving nutrients per_100g].all? { |key| food_snapshot[key] == other.food_snapshot[key] }
  end
end
