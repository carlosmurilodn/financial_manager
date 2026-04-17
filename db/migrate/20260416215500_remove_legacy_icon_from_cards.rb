class RemoveLegacyIconFromCards < ActiveRecord::Migration[8.0]
  def change
    remove_column :cards, :icon, :string
  end
end
