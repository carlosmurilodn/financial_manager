class CreateNutritionMeals < ActiveRecord::Migration[8.0]
  def change
    create_table :nutrition_meals do |t|
      t.references :user, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :nutrition_meals, [ :user_id, :occurred_on ]
  end
end
