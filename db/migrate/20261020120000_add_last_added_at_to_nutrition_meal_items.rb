class AddLastAddedAtToNutritionMealItems < ActiveRecord::Migration[8.0]
  def change
    add_column :nutrition_meal_items, :last_added_at, :datetime
  end
end
