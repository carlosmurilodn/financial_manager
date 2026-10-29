class NutritionMealItem < ApplicationRecord
  include HealthDataGithubTracking
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
    %w[serving nutrients per_100g per_100ml].all? { |key| food_snapshot[key] == other.food_snapshot[key] }
  end

  def quantity_unit
    # The legacy quantity_grams column stores the amount in this native unit.
    source == "tabnut" && food_snapshot.dig("serving", "unit") == "ml" ? "ml" : "g"
  end

  def nutrients_per_100
    food_snapshot.fetch("per_100#{quantity_unit}", {})
  end

  private

  def health_data_github_coordinates
    meal_ids = [nutrition_meal_id, nutrition_meal_id_before_last_save].compact.uniq
    NutritionMeal.where(id: meal_ids).pluck(:user_id, :occurred_on)
      .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
  end
end
