class AddBalanceMonthToInstallments < ActiveRecord::Migration[8.0]
  def change
    add_column :installments, :balance_month, :date
  end
end
