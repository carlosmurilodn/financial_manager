class ExpandPersonalHealthDiary < ActiveRecord::Migration[8.0]
  def up
    %i[energy mood routine_satisfaction anxiety overload].each do |name|
      add_column :weekly_health_reviews, name, :integer
      add_check_constraint :weekly_health_reviews, "#{name} IS NULL OR #{name} BETWEEN 1 AND 5", name: "diary_#{name}_range"
    end
    %i[notes feelings thoughts insights needs_response recognition scenario other_need].each do |name|
      add_column :weekly_health_reviews, name, :text
    end
    add_column :weekly_health_reviews, :needs, :jsonb, default: [], null: false
    add_column :weekly_health_reviews, :legacy_imported, :boolean, default: false, null: false
    add_column :weekly_health_reviews, :legacy_wellbeing_id, :bigint
    execute "UPDATE weekly_health_reviews SET legacy_imported = TRUE"
    execute <<~SQL
      INSERT INTO weekly_health_reviews (user_id, week_start, review_kind, energy, mood, routine_satisfaction, notes, legacy_wellbeing_id, legacy_imported, created_at, updated_at)
      SELECT user_id, week_start, 'weekly', energy, mood, routine_satisfaction, notes, id, TRUE, created_at, updated_at FROM weekly_wellbeings
      ON CONFLICT (user_id, review_kind, week_start) DO UPDATE SET
        energy = EXCLUDED.energy, mood = EXCLUDED.mood,
        routine_satisfaction = EXCLUDED.routine_satisfaction, notes = EXCLUDED.notes,
        legacy_wellbeing_id = EXCLUDED.legacy_wellbeing_id, legacy_imported = TRUE
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Reversão requer exportar novos diários e indicadores antes de remover campos. Os registros originais de bem-estar permanecem preservados."
  end
end
