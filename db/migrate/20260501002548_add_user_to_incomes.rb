class AddUserToIncomes < ActiveRecord::Migration[8.0]
  def change
    add_reference :incomes, :user, foreign_key: true
  end
end
