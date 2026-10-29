class CreateHealthDataGithubSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :health_data_github_syncs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.bigint :revision, null: false, default: 1
      t.bigint :synced_revision, null: false, default: 0
      t.string :status, null: false, default: "pending"
      t.text :error_message
      t.datetime :last_attempt_at
      t.datetime :last_success_at
      t.timestamps
    end
    add_index :health_data_github_syncs, [:user_id, :occurred_on], unique: true
    add_check_constraint :health_data_github_syncs,
      "revision >= synced_revision AND synced_revision >= 0", name: "health_data_github_syncs_revisions"
    add_check_constraint :health_data_github_syncs,
      "status IN ('pending', 'succeeded', 'failed')", name: "health_data_github_syncs_status"
  end
end
