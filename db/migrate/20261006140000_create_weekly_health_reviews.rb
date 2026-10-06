class CreateWeeklyHealthReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_health_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.date :week_start, null: false
      t.text :worked_well
      t.text :obstacles
      t.text :within_control
      t.text :next_adjustments
      t.text :minimum_goal
      t.timestamps
    end

    add_index :weekly_health_reviews, [ :user_id, :week_start ], unique: true
    add_check_constraint :weekly_health_reviews, "EXTRACT(ISODOW FROM week_start) = 1", name: "weekly_health_reviews_start_on_monday"

    reversible do |direction|
      direction.up { execute "ALTER TABLE weekly_health_reviews ENABLE ROW LEVEL SECURITY" }
    end
  end
end
