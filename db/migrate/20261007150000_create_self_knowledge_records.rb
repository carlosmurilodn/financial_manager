class CreateSelfKnowledgeRecords < ActiveRecord::Migration[8.0]
  def up
    create_table :health_journal_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :entry_date, null: false
      %i[mood energy tension].each { |field| t.integer field }
      %i[main_thought meaningful_event emotions positive_moment needs_notes reflection_answer notes].each { |field| t.text field }
      t.string :reflection_prompt_key
      t.jsonb :needs, default: [], null: false
      t.jsonb :legacy_content, default: {}, null: false
      t.bigint :source_review_id
      t.timestamps
      t.index [:user_id, :entry_date], unique: true
      t.index :source_review_id, unique: true
    end
    create_table :health_weekly_reflections do |t|
      t.references :user, null: false, foreign_key: true
      t.date :week_start, null: false
      t.integer :routine_satisfaction
      %i[recurring_patterns what_helped what_drained thought_patterns avoidance_and_control self_discovery weekly_needs_notes control_reflection proud_of weekly_learning keep_doing change_next_week next_small_step].each { |field| t.text field }
      t.jsonb :weekly_needs, default: [], null: false
      t.jsonb :legacy_content, default: {}, null: false
      t.bigint :source_review_id
      t.timestamps
      t.index [:user_id, :week_start], unique: true
      t.index :source_review_id, unique: true
    end
    %i[mood energy tension].each do |field|
      add_check_constraint :health_journal_entries, "#{field} IS NULL OR #{field} BETWEEN 1 AND 5", name: "journal_#{field}_range"
    end
    add_check_constraint :health_weekly_reflections, "routine_satisfaction IS NULL OR routine_satisfaction BETWEEN 1 AND 5", name: "reflection_routine_range"
    add_check_constraint :health_weekly_reflections, "EXTRACT(ISODOW FROM week_start) = 1", name: "reflection_monday"
    import_records
  end

  def import_records
    execute <<~SQL
      INSERT INTO health_journal_entries (user_id, entry_date, mood, energy, tension, emotions, positive_moment, needs, needs_notes, notes, legacy_content, source_review_id, created_at, updated_at)
      SELECT user_id, week_start, mood, energy, anxiety, feelings, worked_well, needs, needs_response, notes, to_jsonb(r), id, created_at, updated_at
      FROM weekly_health_reviews r WHERE review_kind = 'daily'
      ON CONFLICT (user_id, entry_date) DO NOTHING
    SQL
    execute <<~SQL
      INSERT INTO health_weekly_reflections (user_id, week_start, routine_satisfaction, what_helped, what_drained, thought_patterns, self_discovery, weekly_needs, weekly_needs_notes, control_reflection, proud_of, change_next_week, next_small_step, legacy_content, source_review_id, created_at, updated_at)
      SELECT user_id, week_start, routine_satisfaction, worked_well, obstacles, thoughts, insights, needs, needs_response, within_control, recognition, next_adjustments, minimum_goal, to_jsonb(r), id, created_at, updated_at
      FROM weekly_health_reviews r WHERE review_kind = 'weekly'
      ON CONFLICT (user_id, week_start) DO NOTHING
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Exporte os novos registros antes de reverter. As tabelas anteriores foram preservadas."
  end
end
