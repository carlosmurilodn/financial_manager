class RemoveStepsFromExerciseItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :exercise_items, :steps, :integer
  end
end
