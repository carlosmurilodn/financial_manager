class AddSnapshotFieldsToInstallments < ActiveRecord::Migration[8.0]
  def up
    add_column :installments, :description, :string
    add_reference :installments, :category, foreign_key: true
    add_reference :installments, :card, foreign_key: true
    add_column :installments, :payment_method, :integer

    execute <<~SQL.squish
      UPDATE installments
      SET description = expenses.description,
          category_id = expenses.category_id,
          card_id = expenses.card_id,
          payment_method = expenses.payment_method
      FROM expenses
      WHERE installments.expense_id = expenses.id
    SQL

    change_column_null :installments, :description, false
    change_column_null :installments, :category_id, false
    change_column_null :installments, :payment_method, false
  end

  def down
    remove_column :installments, :description
    remove_reference :installments, :category, foreign_key: true
    remove_reference :installments, :card, foreign_key: true
    remove_column :installments, :payment_method
  end
end
