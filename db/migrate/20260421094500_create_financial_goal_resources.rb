class CreateFinancialGoalResources < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_goal_resources do |t|
      t.references :financial_goal, null: false, foreign_key: true
      t.integer :resource_type, null: false, default: 0
      t.string :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false, default: 0
      t.boolean :include_in_total, null: false, default: true
      t.text :notes

      t.timestamps
    end

    add_index :financial_goal_resources, :resource_type
  end
end
