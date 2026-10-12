class CreateNutritionRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :nutrition_recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :final_weight_grams, precision: 12, scale: 4, null: false
      t.integer :servings, null: false
      t.timestamps
    end

    add_index :nutrition_recipes, [ :user_id, :name ]
    add_check_constraint :nutrition_recipes, "length(trim(name)) > 0", name: "nutrition_recipes_nonempty_name"
    add_check_constraint :nutrition_recipes, "final_weight_grams > 0", name: "nutrition_recipes_positive_weight"
    add_check_constraint :nutrition_recipes, "servings > 0", name: "nutrition_recipes_positive_servings"
  end
end
