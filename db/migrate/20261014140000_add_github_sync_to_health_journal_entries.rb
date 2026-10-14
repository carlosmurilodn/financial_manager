class AddGithubSyncToHealthJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :health_journal_entries, :github_sync, :jsonb, default: {}, null: false
  end
end
