class AddSchedulingToWritingGithubSyncs < ActiveRecord::Migration[8.0]
  def change
    change_table :writing_github_syncs do |t|
      t.boolean :pending_changes, null: false, default: false
      t.datetime :first_pending_at
      t.datetime :scheduled_at
      t.datetime :retry_at
      t.datetime :next_pending_at
      t.bigint :content_revision, null: false, default: 0
      t.bigint :synced_revision, null: false, default: 0
      t.bigint :sending_revision
    end
    add_index :writing_github_syncs, :scheduled_at, where: "pending_changes", name: "index_writing_github_syncs_pending_schedule"
    add_check_constraint :writing_github_syncs, "content_revision >= synced_revision AND synced_revision >= 0", name: "writing_github_syncs_valid_revisions"
    add_check_constraint :writing_github_syncs, "NOT pending_changes OR (first_pending_at IS NOT NULL AND scheduled_at IS NOT NULL)", name: "writing_github_syncs_pending_schedule"
    reversible do |direction|
      direction.up do
        execute <<~SQL
          UPDATE writing_github_syncs
          SET pending_changes = TRUE,
              first_pending_at = COALESCE(last_attempt_at, CURRENT_TIMESTAMP),
              scheduled_at = COALESCE(last_attempt_at, CURRENT_TIMESTAMP) + INTERVAL '5 minutes'
          WHERE status IN ('failed', 'processing')
        SQL
      end
    end
  end
end
