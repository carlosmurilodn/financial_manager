class CreateWeightEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :weight_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :measured_on, null: false
      t.decimal :weight_kg, precision: 5, scale: 2, null: false
      t.timestamps
    end

    add_index :weight_entries, [ :user_id, :measured_on ], unique: true
    add_check_constraint :weight_entries, "weight_kg > 0", name: "weight_entries_positive_weight"
  end
end
