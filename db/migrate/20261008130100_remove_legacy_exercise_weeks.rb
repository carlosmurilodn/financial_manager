class RemoveLegacyExerciseWeeks < ActiveRecord::Migration[8.0]
  LEGACY_EXERCISE_NAMES = [ "Musculação", "Treino Funcional", "Caminhada" ].freeze

  def up
    weekly_health_goal_ids = select_values(<<~SQL.squish)
      SELECT id
      FROM weekly_health_goals
      WHERE name IN (#{LEGACY_EXERCISE_NAMES.map { |name| quote(name) }.join(", ")})
    SQL

    return if weekly_health_goal_ids.empty?

    quoted_ids = weekly_health_goal_ids.map { |id| quote(id) }.join(", ")
    execute "DELETE FROM weekly_health_goal_days WHERE weekly_health_goal_id IN (#{quoted_ids})"
    execute "DELETE FROM weekly_health_goals WHERE id IN (#{quoted_ids})"
    execute <<~SQL.squish
      DELETE FROM weekly_health_plans
      WHERE NOT EXISTS (
        SELECT 1
        FROM weekly_health_goals
        WHERE weekly_health_goals.weekly_health_plan_id = weekly_health_plans.id
      )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
