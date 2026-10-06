class CreateHealthWeightGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :health_weight_goals do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.decimal :target_weight, precision: 5, scale: 2, null: false
      t.decimal :milestone_weights, precision: 5, scale: 2, array: true, default: [], null: false
      t.timestamps
    end
    add_check_constraint :health_weight_goals, "target_weight > 0", name: "health_weight_goals_positive_target"

    reversible do |direction|
      direction.up { execute "ALTER TABLE health_weight_goals ENABLE ROW LEVEL SECURITY" }
    end
  end
end
