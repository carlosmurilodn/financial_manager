class SupportContinuousNutritionMealItems < ActiveRecord::Migration[8.0]
  def up
    %i[calories carbohydrates proteins fats].each do |nutrient|
      change_column_null :nutrition_meal_items, nutrient, true
    end
    add_column :nutrition_meal_items, :addition_tokens, :jsonb, null: false, default: []
  end

  def down
    if select_value("SELECT COUNT(*) FROM nutrition_meal_items WHERE calories IS NULL OR carbohydrates IS NULL OR proteins IS NULL OR fats IS NULL").to_i.positive?
      raise ActiveRecord::IrreversibleMigration, "Itens com nutrientes ausentes precisam ser tratados antes do rollback."
    end
    remove_column :nutrition_meal_items, :addition_tokens
    %i[calories carbohydrates proteins fats].each do |nutrient|
      change_column_null :nutrition_meal_items, nutrient, false
    end
  end
end
