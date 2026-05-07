class AddSourceToFinancialGoalResources < ActiveRecord::Migration[8.0]
  def change
    add_column :financial_goal_resources, :source_type, :string
    add_column :financial_goal_resources, :source_id, :bigint

    add_index :financial_goal_resources, [ :source_type, :source_id ]
  end
end
