class CreateNutritionMealItems < ActiveRecord::Migration[8.0]
  def change
    create_table :nutrition_meal_items do |t|
      t.references :nutrition_meal, null: false, foreign_key: true
      t.string :source, null: false
      t.string :source_id, null: false
      t.string :name, null: false
      t.decimal :quantity_grams, precision: 12, scale: 4, null: false
      t.decimal :calories, precision: 12, scale: 4, null: false
      t.decimal :carbohydrates, precision: 12, scale: 4, null: false
      t.decimal :proteins, precision: 12, scale: 4, null: false
      t.decimal :fats, precision: 12, scale: 4, null: false
      t.timestamps
    end

    add_index :nutrition_meal_items, [ :source, :source_id ]
    add_check_constraint :nutrition_meal_items, "source IN ('taco', 'custom', 'recipe')", name: "nutrition_meal_items_valid_source"
    add_check_constraint :nutrition_meal_items, "quantity_grams > 0", name: "nutrition_meal_items_positive_quantity"
    add_check_constraint :nutrition_meal_items, "calories >= 0 AND carbohydrates >= 0 AND proteins >= 0 AND fats >= 0", name: "nutrition_meal_items_nonnegative_nutrients"
  end
end
