class MoveInstallmentsIntoExpenses < ActiveRecord::Migration[8.0]
  CREDITO_PARCELADO = 3

  def up
    add_column :expenses, :installment_group_id, :bigint
    add_index :expenses, :installment_group_id

    execute <<~SQL
      UPDATE expenses
      SET installment_group_id = id
      WHERE payment_method = #{CREDITO_PARCELADO}
    SQL

    execute <<~SQL
      INSERT INTO expenses (
        amount,
        date,
        balance_month,
        description,
        category_id,
        card_id,
        payment_method,
        paid,
        created_at,
        updated_at,
        installments_count,
        current_installment,
        is_parent,
        installment_group_id
      )
      SELECT
        installments.amount,
        installments.due_date,
        installments.balance_month,
        installments.description,
        installments.category_id,
        installments.card_id,
        installments.payment_method,
        installments.paid,
        installments.created_at,
        installments.updated_at,
        installments.installments_count,
        installments.number,
        FALSE,
        installments.expense_id
      FROM installments
    SQL

    drop_table :installments
    remove_column :expenses, :is_parent, :boolean
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Use the previous schema if you need to restore installments"
  end
end
