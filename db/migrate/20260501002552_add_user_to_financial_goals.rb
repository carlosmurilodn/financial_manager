class AddUserToFinancialGoals < ActiveRecord::Migration[8.0]
  def change
    add_reference :financial_goals, :user, foreign_key: true
  end
end
