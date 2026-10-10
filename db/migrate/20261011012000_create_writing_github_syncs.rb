class CreateWritingGithubSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :writing_github_syncs do |t|
      t.references :writing_book, null: false, foreign_key: true, index: { unique: true }
      t.string :status, null: false, default: "never"
      t.datetime :last_attempt_at
      t.datetime :last_success_at
      t.text :error_message
      t.string :repository
      t.string :branch
      t.integer :created_count, null: false, default: 0
      t.integer :updated_count, null: false, default: 0
      t.integer :unchanged_count, null: false, default: 0
      t.jsonb :obsolete_files, null: false, default: []
      t.timestamps
    end
    add_check_constraint :writing_github_syncs, "status IN ('never', 'processing', 'succeeded', 'failed')", name: "writing_github_syncs_valid_status"
    add_check_constraint :writing_github_syncs, "created_count >= 0 AND updated_count >= 0 AND unchanged_count >= 0", name: "writing_github_syncs_valid_counts"
  end
end
