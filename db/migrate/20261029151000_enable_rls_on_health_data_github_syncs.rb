class EnableRlsOnHealthDataGithubSyncs < ActiveRecord::Migration[8.0]
  def up
    execute "ALTER TABLE health_data_github_syncs ENABLE ROW LEVEL SECURITY"
  end

  def down
    execute "ALTER TABLE health_data_github_syncs DISABLE ROW LEVEL SECURITY"
  end
end
