class AddCategoryToIncomes < ActiveRecord::Migration[8.0]
  def change
    add_reference :incomes, :category, foreign_key: true
  end
end
