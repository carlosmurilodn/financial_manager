class AddCategoryToFinancialGoals < ActiveRecord::Migration[8.0]
  def change
    add_reference :financial_goals, :category, foreign_key: true
  end
end
