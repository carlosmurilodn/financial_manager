class ProtectSelfKnowledgeTables < ActiveRecord::Migration[8.0]
  def up
    execute "ALTER TABLE health_journal_entries ENABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE health_weekly_reflections ENABLE ROW LEVEL SECURITY"
  end

  def down
    execute "ALTER TABLE health_journal_entries DISABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE health_weekly_reflections DISABLE ROW LEVEL SECURITY"
  end
end
