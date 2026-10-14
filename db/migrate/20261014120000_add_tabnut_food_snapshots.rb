class AddTabnutFoodSnapshots < ActiveRecord::Migration[8.0]
  def up
    add_column :nutrition_meal_items, :food_snapshot, :jsonb, default: {}, null: false
    remove_check_constraint :nutrition_meal_items, name: "nutrition_meal_items_valid_source"
    add_check_constraint :nutrition_meal_items, "source IN ('taco', 'custom', 'recipe', 'tabnut')", name: "nutrition_meal_items_valid_source"
  end

  def down
    if select_value("SELECT COUNT(*) FROM nutrition_meal_items WHERE source = 'tabnut'").to_i.positive?
      raise ActiveRecord::IrreversibleMigration, "Existem alimentos TabNut no histórico."
    end
    remove_check_constraint :nutrition_meal_items, name: "nutrition_meal_items_valid_source"
    add_check_constraint :nutrition_meal_items, "source IN ('taco', 'custom', 'recipe')", name: "nutrition_meal_items_valid_source"
    remove_column :nutrition_meal_items, :food_snapshot
  end
end
