class AddDietStatusToWeeklyHealthGoalDays < ActiveRecord::Migration[8.0]
  def up
    add_column :weekly_health_goal_days, :diet_status, :string
    add_check_constraint :weekly_health_goal_days, "diet_status IS NULL OR diet_status IN ('full', 'partial', 'none')", name: "weekly_health_goal_days_diet_status"
    execute <<~SQL
      UPDATE weekly_health_goal_days AS days
      SET diet_status = CASE WHEN days.completed THEN 'full' ELSE 'none' END
      FROM weekly_health_goals AS goals
      WHERE days.weekly_health_goal_id = goals.id AND lower(goals.name) = 'alimentação'
    SQL
  end

  def down
    remove_check_constraint :weekly_health_goal_days, name: "weekly_health_goal_days_diet_status"
    remove_column :weekly_health_goal_days, :diet_status
  end
end
