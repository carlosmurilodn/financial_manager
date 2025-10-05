class CreateIncomes < ActiveRecord::Migration[8.0]
  def change
    create_table :incomes do |t|
      t.decimal :amount
      t.date :date
      t.date :balance_month
      t.string :description
      t.boolean :paid

      t.timestamps
    end
  end
end
