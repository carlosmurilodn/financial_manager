class AddInstallmentFieldsToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_column :expenses, :installments_count, :integer, default: 1, null: false
    add_column :expenses, :current_installment, :integer, default: 1, null: false
    add_column :expenses, :first_due_date, :date
    add_column :expenses, :is_parent, :boolean, default: false
    add_reference :expenses, :parent_expense, foreign_key: { to_table: :expenses }
  end
end
