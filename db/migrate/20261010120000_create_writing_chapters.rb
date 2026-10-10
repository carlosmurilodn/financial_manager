class CreateWritingChapters < ActiveRecord::Migration[8.0]
  def change
    create_table :writing_chapters do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :title, null: false
      t.jsonb :content, null: false, default: { type: "doc", content: [ { type: "paragraph", attrs: { firstLineIndent: true, textAlign: "left" } } ] }
      t.integer :document_version, null: false, default: 1
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
  end
end
