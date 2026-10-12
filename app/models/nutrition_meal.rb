class NutritionMeal < ApplicationRecord
  belongs_to :user
  has_many :nutrition_meal_items, dependent: :destroy, inverse_of: :nutrition_meal

  validates :occurred_on, presence: true
  validates :name, presence: true
end
