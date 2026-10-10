class ProtectWritingGithubSyncs < ActiveRecord::Migration[8.0]
  def up
    # Rails accesses this table as its owner. No Supabase Data API access is needed.
    execute "ALTER TABLE writing_github_syncs ENABLE ROW LEVEL SECURITY"
  end

  def down
    execute "ALTER TABLE writing_github_syncs DISABLE ROW LEVEL SECURITY"
  end
end
