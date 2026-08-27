class AddColorToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :color, :string, null: false, default: "#2563EB"
  end
end
