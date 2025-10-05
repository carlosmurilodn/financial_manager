class AddFieldsToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :total_limit, :decimal
    add_column :cards, :remaining_limit, :decimal
    add_column :cards, :due_day, :integer
    add_column :cards, :best_day, :integer
  end
end
