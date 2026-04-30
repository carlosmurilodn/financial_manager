class AddPaidAtToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_column :expenses, :paid_at, :datetime
    add_index :expenses, :paid_at
  end
end
