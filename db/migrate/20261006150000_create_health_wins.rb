class CreateHealthWins < ActiveRecord::Migration[8.0]
  def change
    create_table :health_wins do |t|
      t.references :user, null: false, foreign_key: true
      t.date :achieved_on, null: false
      t.text :description, null: false
      t.timestamps
    end
    add_index :health_wins, [ :user_id, :achieved_on ]

    reversible do |direction|
      direction.up { execute "ALTER TABLE health_wins ENABLE ROW LEVEL SECURITY" }
    end
  end
end
