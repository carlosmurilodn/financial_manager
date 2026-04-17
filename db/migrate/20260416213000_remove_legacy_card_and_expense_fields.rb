class RemoveLegacyCardAndExpenseFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :cards, :remaining_limit, :decimal
    remove_column :expenses, :first_due_date, :date
    remove_reference :expenses, :parent_expense, foreign_key: { to_table: :expenses }, index: true
  end
end
