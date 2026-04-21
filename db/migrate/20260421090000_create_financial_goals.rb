class CreateFinancialGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_goals do |t|
      t.string :description, null: false
      t.decimal :target_amount, precision: 12, scale: 2, null: false
      t.date :due_date, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.text :notes

      t.timestamps
    end

    add_index :financial_goals, :status
    add_index :financial_goals, :priority
    add_index :financial_goals, :due_date
  end
end
