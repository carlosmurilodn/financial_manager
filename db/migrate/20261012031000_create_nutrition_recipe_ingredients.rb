class CreateNutritionRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :nutrition_recipe_ingredients do |t|
      t.references :nutrition_recipe, null: false, foreign_key: true
      t.string :source, null: false
      t.string :source_id, null: false
      t.string :name, null: false
      t.decimal :quantity_grams, precision: 12, scale: 4, null: false
      # Snapshot per 100 g, independent of later catalog changes or deletion.
      t.float :calories
      t.float :carbohydrates
      t.float :proteins
      t.float :fats
      t.timestamps
    end

    add_index :nutrition_recipe_ingredients, [ :source, :source_id ]
    add_check_constraint :nutrition_recipe_ingredients, "source IN ('taco', 'custom')", name: "nutrition_recipe_ingredients_valid_source"
    add_check_constraint :nutrition_recipe_ingredients, "quantity_grams > 0", name: "nutrition_recipe_ingredients_positive_quantity"
  end
end
