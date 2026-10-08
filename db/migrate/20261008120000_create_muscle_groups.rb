class CreateMuscleGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :muscle_groups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :muscle_groups, [ :user_id, :name ], unique: true
    add_index :muscle_groups, [ :user_id, :active ]
    add_index :muscle_groups, [ :user_id, :position ]
  end
end
