class AddColorToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :color, :string
  end
end
