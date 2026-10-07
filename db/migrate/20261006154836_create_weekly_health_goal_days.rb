class CreateWeeklyHealthGoalDays < ActiveRecord::Migration[8.0]
  class MigrationWeeklyHealthGoal < ApplicationRecord
    self.table_name = "weekly_health_goals"

    belongs_to :weekly_health_plan, class_name: "CreateWeeklyHealthGoalDays::MigrationWeeklyHealthPlan"
  end

  class MigrationWeeklyHealthGoalDay < ApplicationRecord
    self.table_name = "weekly_health_goal_days"
  end

  class MigrationWeeklyHealthPlan < ApplicationRecord
    self.table_name = "weekly_health_plans"
  end

  def change
    create_table :weekly_health_goal_days do |t|
      t.references :weekly_health_goal, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :weekly_health_goal_days,
              [ :weekly_health_goal_id, :occurred_on ],
              unique: true,
              name: "index_weekly_health_goal_days_on_goal_and_date"

    reversible do |direction|
      direction.up { backfill_completed_days }
    end
  end

  private

  def backfill_completed_days
    MigrationWeeklyHealthGoal.includes(:weekly_health_plan).find_each do |goal|
      goal.completed_count.to_i.times do |offset|
        next if offset > 6

        MigrationWeeklyHealthGoalDay.create!(
          weekly_health_goal_id: goal.id,
          occurred_on: goal.weekly_health_plan.week_start + offset.days,
          completed: true,
          created_at: Time.current,
          updated_at: Time.current
        )
      end
    end
  end
end
