class CreateWeeklyHealthPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_health_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.date :week_start, null: false
      t.timestamps
    end
    add_index :weekly_health_plans, [ :user_id, :week_start ], unique: true
    add_check_constraint :weekly_health_plans, "EXTRACT(ISODOW FROM week_start) = 1", name: "weekly_health_plans_start_on_monday"

    create_table :weekly_health_goals do |t|
      t.references :weekly_health_plan, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :target_count, null: false
      t.integer :completed_count, default: 0, null: false
      t.string :notes
      t.timestamps
    end
    add_check_constraint :weekly_health_goals, "target_count > 0 AND completed_count >= 0", name: "weekly_health_goals_valid_counts"

    reversible do |direction|
      direction.up do
        execute "ALTER TABLE weekly_health_plans ENABLE ROW LEVEL SECURITY"
        execute "ALTER TABLE weekly_health_goals ENABLE ROW LEVEL SECURITY"
      end
    end
  end
end
