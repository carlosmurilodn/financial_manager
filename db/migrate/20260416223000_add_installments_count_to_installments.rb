class AddInstallmentsCountToInstallments < ActiveRecord::Migration[8.0]
  def up
    add_column :installments, :installments_count, :integer

    execute <<~SQL.squish
      UPDATE installments
      SET installments_count = expenses.installments_count
      FROM expenses
      WHERE installments.expense_id = expenses.id
    SQL

    change_column_null :installments, :installments_count, false
  end

  def down
    remove_column :installments, :installments_count
  end
end
