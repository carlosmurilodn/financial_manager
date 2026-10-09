class RemoveWeeklyExerciseTracking < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      DELETE FROM weekly_health_goal_days
      WHERE weekly_health_goal_id IN (
        SELECT id FROM weekly_health_goals WHERE #{legacy_exercise_condition}
      )
    SQL
    execute "DELETE FROM weekly_health_goals WHERE #{legacy_exercise_condition}"
    execute <<~SQL
      DELETE FROM weekly_health_plans
      WHERE NOT EXISTS (
        SELECT 1 FROM weekly_health_goals
        WHERE weekly_health_goals.weekly_health_plan_id = weekly_health_plans.id
      )
    SQL

    remove_check_constraint :weekly_health_goal_days, name: "weekly_health_goal_days_exercise_status"
    remove_columns :weekly_health_goal_days, :exercise_status, :duration_minutes, :distance_km,
      :steps, :muscle_groups, :exercise_focus, :exercise_intensity, :exercise_notes
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Metas e marcações antigas de exercícios foram excluídas."
  end

  private

  def legacy_exercise_condition
    <<~SQL.squish
      regexp_replace(translate(lower(trim(name)), 'áàâãéêíóôõúç', 'aaaaeeiooouc'), '[^a-z0-9]+', '-', 'g')
      IN ('musculacao', 'treino', 'treinar', 'treino-funcional', 'funcional', 'caminhada', 'caminhar', 'ergometria')
    SQL
  end
end
