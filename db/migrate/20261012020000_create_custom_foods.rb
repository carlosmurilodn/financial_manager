class CreateCustomFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_foods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category, null: false
      t.decimal :calories, precision: 12, scale: 4
      t.decimal :carbohydrates, precision: 12, scale: 4
      t.decimal :proteins, precision: 12, scale: 4
      t.decimal :fats, precision: 12, scale: 4
      t.decimal :fiber, precision: 12, scale: 4
      t.timestamps
    end

    add_index :custom_foods, [ :user_id, :name ]
    add_index :custom_foods, [ :user_id, :category ]
    add_check_constraint :custom_foods, "length(trim(name)) > 0", name: "custom_foods_nonempty_name"
    add_check_constraint :custom_foods, "length(trim(category)) > 0", name: "custom_foods_nonempty_category"
    %w[calories carbohydrates proteins fats fiber].each do |nutrient|
      add_check_constraint :custom_foods, "#{nutrient} IS NULL OR #{nutrient} >= 0", name: "custom_foods_nonnegative_#{nutrient}"
    end
  end
end
