class AddExerciseDetailsToWeeklyHealthGoalDays < ActiveRecord::Migration[8.0]
  def change
    add_column :weekly_health_goal_days, :exercise_status, :string
    add_column :weekly_health_goal_days, :duration_minutes, :decimal, precision: 7, scale: 2
    add_column :weekly_health_goal_days, :distance_km, :decimal, precision: 7, scale: 2
    add_column :weekly_health_goal_days, :steps, :integer
    add_column :weekly_health_goal_days, :muscle_groups, :string, limit: 150
    add_column :weekly_health_goal_days, :exercise_focus, :string
    add_column :weekly_health_goal_days, :exercise_intensity, :string
    add_column :weekly_health_goal_days, :exercise_notes, :text
    add_check_constraint :weekly_health_goal_days,
      "exercise_status IS NULL OR exercise_status IN ('', 'completed', 'not_completed')",
      name: "weekly_health_goal_days_exercise_status"
  end
end
