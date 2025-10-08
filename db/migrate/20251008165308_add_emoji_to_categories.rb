class AddEmojiToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :emoji, :string
  end
end
