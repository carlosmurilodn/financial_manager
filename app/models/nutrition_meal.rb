class NutritionMeal < ApplicationRecord
  include HealthDataGithubTracking

  attr_accessor :skip_health_data_github_tracking
  belongs_to :user
  has_many :nutrition_meal_items, dependent: :destroy, inverse_of: :nutrition_meal

  validates :occurred_on, presence: true
  validates :name, presence: true

  private

  def health_data_github_coordinates
    return {} if skip_health_data_github_tracking

    coordinates = [[user_id, occurred_on]]
    if saved_change_to_occurred_on? || saved_change_to_user_id?
      coordinates << [user_id_before_last_save || user_id, occurred_on_before_last_save]
    end
    coordinates.select { |_, date| date }.group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
  end
end
