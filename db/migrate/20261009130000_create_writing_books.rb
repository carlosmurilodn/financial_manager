class CreateWritingBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :writing_books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :subtitle
      t.string :author
      t.string :genre, null: false
      t.string :secondary_genres, array: true, default: [], null: false
      t.string :target_audience
      t.text :synopsis
      t.text :premise
      t.text :notes
      t.string :status, default: "idea", null: false
      t.date :started_on
      t.date :expected_completion_on
      t.timestamps
    end
    add_index :writing_books, [ :user_id, :status ]
    add_index :writing_books, [ :user_id, :genre ]
  end
end
