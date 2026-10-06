class CreateWeeklyWellbeings < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_wellbeings do |t|
      t.references :user, null: false, foreign_key: true
      t.date :week_start, null: false
      t.integer :energy, null: false
      t.integer :mood, null: false
      t.integer :routine_satisfaction, null: false
      t.text :notes
      t.timestamps
    end
    add_index :weekly_wellbeings, [ :user_id, :week_start ], unique: true
    add_check_constraint :weekly_wellbeings, "EXTRACT(ISODOW FROM week_start) = 1", name: "weekly_wellbeings_start_on_monday"
    add_check_constraint :weekly_wellbeings, "energy BETWEEN 1 AND 5 AND mood BETWEEN 1 AND 5 AND routine_satisfaction BETWEEN 1 AND 5", name: "weekly_wellbeings_valid_scores"
    reversible do |direction|
      direction.up { execute "ALTER TABLE weekly_wellbeings ENABLE ROW LEVEL SECURITY" }
    end
  end
end
