class CreateStrengthExerciseCatalogs < ActiveRecord::Migration[8.0]
  def change
    create_table :strength_exercise_catalogs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :muscle_group, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :strength_exercise_catalogs, [ :user_id, :name ], unique: true
    add_index :strength_exercise_catalogs, [ :user_id, :muscle_group_id ]
    add_index :strength_exercise_catalogs, [ :user_id, :active ]
    add_index :strength_exercise_catalogs, [ :user_id, :position ]
  end
end
