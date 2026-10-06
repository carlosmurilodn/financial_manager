class ConvertHealthWeightGoalsToIndividualGoals < ActiveRecord::Migration[8.0]
  class MigrationHealthWeightGoal < ApplicationRecord
    self.table_name = "health_weight_goals"
  end

  def up
    add_column :health_weight_goals, :goal_type, :string, null: false, default: "intermediate"
    add_column :health_weight_goals, :position, :integer, null: false, default: 0

    remove_index :health_weight_goals, name: "index_health_weight_goals_on_user_id"

    MigrationHealthWeightGoal.reset_column_information
    MigrationHealthWeightGoal.find_each do |goal|
      goal.milestone_weights.each_with_index do |weight, index|
        MigrationHealthWeightGoal.create!(
          user_id: goal.user_id,
          target_weight: weight,
          goal_type: "intermediate",
          position: index + 1,
          created_at: goal.created_at,
          updated_at: goal.updated_at
        )
      end

      goal.update!(goal_type: "final", position: goal.milestone_weights.size + 1)
    end

    remove_column :health_weight_goals, :milestone_weights

    add_index :health_weight_goals, :user_id
    add_index :health_weight_goals, [ :user_id, :goal_type ],
              unique: true,
              where: "goal_type = 'final'",
              name: "index_health_weight_goals_on_user_id_final_type"
  end

  def down
    add_column :health_weight_goals, :milestone_weights, :decimal,
               precision: 5,
               scale: 2,
               array: true,
               default: [],
               null: false

    remove_index :health_weight_goals, name: "index_health_weight_goals_on_user_id_final_type"
    remove_index :health_weight_goals, name: "index_health_weight_goals_on_user_id"

    MigrationHealthWeightGoal.reset_column_information
    MigrationHealthWeightGoal.where(goal_type: "final").find_each do |final_goal|
      milestones = MigrationHealthWeightGoal
        .where(user_id: final_goal.user_id, goal_type: "intermediate")
        .order(:position, target_weight: :desc)
        .pluck(:target_weight)

      final_goal.update!(milestone_weights: milestones)
    end

    MigrationHealthWeightGoal.where(goal_type: "intermediate").delete_all

    remove_column :health_weight_goals, :position
    remove_column :health_weight_goals, :goal_type

    add_index :health_weight_goals, :user_id, unique: true
  end
end
