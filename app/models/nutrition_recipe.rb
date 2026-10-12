class NutritionRecipe < ApplicationRecord
  belongs_to :user
  has_many :nutrition_recipe_ingredients, dependent: :destroy, inverse_of: :nutrition_recipe

  accepts_nested_attributes_for :nutrition_recipe_ingredients, allow_destroy: true

  validates :name, presence: true
  validates :final_weight_grams, numericality: { greater_than: 0, less_than: 100_000_000 }
  validates :servings, numericality: { only_integer: true, greater_than: 0, less_than: 2_147_483_648 }
  validate :has_ingredients

  scope :search_by_name, ->(query) {
    where("name ILIKE ?", "%#{sanitize_sql_like(query.to_s)}%") if query.present?
  }

  private

  def has_ingredients
    return if nutrition_recipe_ingredients.reject(&:marked_for_destruction?).any?

    errors.add(:base, "Adicione pelo menos um ingrediente.")
  end
end
