class AddCurrentAmountToFinancialGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :financial_goals, :current_amount, :decimal, precision: 12, scale: 2, null: false, default: 0
  end
end
