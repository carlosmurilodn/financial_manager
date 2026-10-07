class CreateDailyCalorieEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_calorie_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.decimal :consumed_calories, precision: 12, scale: 2
      t.decimal :reference_weight_kg, precision: 5, scale: 2
      t.date :reference_weight_date
      t.decimal :height_cm, precision: 5, scale: 2
      t.date :birth_date
      t.integer :age
      t.string :formula_sex
      t.boolean :trained, null: false, default: false
      t.boolean :walked, null: false, default: false
      t.decimal :activity_factor, precision: 4, scale: 3, null: false, default: "1.2"
      t.decimal :bmr, precision: 14, scale: 4
      t.decimal :tdee, precision: 18, scale: 7
      t.decimal :calorie_deficit, precision: 18, scale: 7
      t.string :calculation_status, null: false, default: "missing_consumption"
      t.datetime :calculated_at
      t.timestamps
    end

    add_index :daily_calorie_entries, [ :user_id, :occurred_on ], unique: true
    add_check_constraint :daily_calorie_entries, "consumed_calories IS NULL OR consumed_calories >= 0", name: "daily_calorie_entries_nonnegative_consumption"
    add_check_constraint :daily_calorie_entries, "activity_factor IN (1.2, 1.375, 1.55, 1.725)", name: "daily_calorie_entries_valid_factor"
    add_check_constraint :daily_calorie_entries, "calculation_status IN ('calculated', 'missing_consumption', 'missing_profile', 'missing_weight', 'invalid_profile')", name: "daily_calorie_entries_valid_status"
    add_check_constraint :daily_calorie_entries, "reference_weight_date IS NULL OR reference_weight_date <= occurred_on", name: "daily_calorie_entries_reference_not_later"
    add_check_constraint :daily_calorie_entries, "(bmr IS NULL OR bmr > 0) AND (tdee IS NULL OR tdee > 0)", name: "daily_calorie_entries_positive_expenditure"

    reversible do |direction|
      direction.up { execute "ALTER TABLE daily_calorie_entries ENABLE ROW LEVEL SECURITY" }
    end
  end
end
