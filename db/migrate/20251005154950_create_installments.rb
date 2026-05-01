class CreateInstallments < ActiveRecord::Migration[8.0]
  def change
    create_table :installments do |t|
      t.references :expense, null: false, foreign_key: true
      t.integer :number
      t.decimal :amount, precision: 10, scale: 2
      t.date :due_date
      t.boolean :paid, default: false
      t.date :payment_date

      t.timestamps
    end
  end
end
