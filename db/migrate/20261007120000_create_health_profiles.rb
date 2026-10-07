class CreateHealthProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :health_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.decimal :height_cm, precision: 5, scale: 2, null: false
      t.date :birth_date, null: false
      t.string :formula_sex, null: false
      t.timestamps
    end

    add_check_constraint :health_profiles, "height_cm > 0 AND height_cm < 1000", name: "health_profiles_valid_height"
    add_check_constraint :health_profiles, "formula_sex IN ('male', 'female')", name: "health_profiles_valid_formula_sex"

    reversible do |direction|
      direction.up { execute "ALTER TABLE health_profiles ENABLE ROW LEVEL SECURITY" }
    end
  end
end
