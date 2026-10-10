class CreateWritingActivityEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :writing_books, :writing_history_started_at, :datetime
    add_column :writing_books, :writing_history_initial_words, :bigint
    create_table :writing_activity_events do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.bigint :chapter_id
      t.bigint :scene_id
      t.string :chapter_title, null: false
      t.string :scene_title
      t.string :operation, null: false
      t.datetime :occurred_at, null: false
      t.bigint :previous_words, null: false
      t.bigint :current_words, null: false
      t.bigint :added_words, null: false
      t.bigint :removed_words, null: false
      t.bigint :net_words, null: false
      t.bigint :book_words, null: false
      t.timestamps
    end
    add_index :writing_activity_events, [ :writing_book_id, :occurred_at, :id ], name: "idx_writing_activity_history"
    add_index :writing_activity_events, [ :writing_book_id, :chapter_id, :occurred_at ], name: "idx_writing_activity_chapter"
    add_check_constraint :writing_activity_events,
      "previous_words >= 0 AND current_words >= 0 AND added_words >= 0 AND removed_words >= 0 AND book_words >= 0 AND net_words = added_words - removed_words",
      name: "writing_activity_valid_counts"
    reversible do |direction|
      direction.up { execute "ALTER TABLE writing_activity_events ENABLE ROW LEVEL SECURITY" }
    end
  end
end
