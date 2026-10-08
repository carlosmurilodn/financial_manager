class CreateExerciseEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :exercise_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :performed_on, null: false

      t.timestamps
    end

    add_index :exercise_entries, [ :user_id, :performed_on ]

    create_table :exercise_items do |t|
      t.references :exercise_entry, null: false, foreign_key: true
      t.string :exercise_type, null: false
      t.integer :duration_minutes
      t.string :intensity
      t.integer :steps
      t.text :notes

      t.timestamps
    end

    add_index :exercise_items, :exercise_type

    create_table :strength_exercise_logs do |t|
      t.references :exercise_item, null: false, foreign_key: true
      t.references :muscle_group, null: false, foreign_key: true
      t.references :strength_exercise_catalog, null: false, foreign_key: true
      t.integer :sets, null: false

      t.timestamps
    end
  end
end
