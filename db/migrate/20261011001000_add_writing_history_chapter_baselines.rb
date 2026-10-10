class AddWritingHistoryChapterBaselines < ActiveRecord::Migration[8.0]
  def change
    add_column :writing_books, :writing_history_initial_chapters, :jsonb, default: {}, null: false
  end
end
