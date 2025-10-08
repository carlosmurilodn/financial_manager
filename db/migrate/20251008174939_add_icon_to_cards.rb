class AddIconToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :icon, :string
  end
end
