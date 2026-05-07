class AddColorToFinancialGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :financial_goals, :color, :string
  end
end
