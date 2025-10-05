class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.decimal :amount
      t.date :date
      t.date :balance_month
      t.string :description
      t.references :category, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.integer :payment_method
      t.boolean :paid

      t.timestamps
    end
  end
end
