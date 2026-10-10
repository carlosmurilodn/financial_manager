class CreatePhilosophicalWorkshopPhilosophers < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_philosophers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :historical_period
      t.string :philosophical_school
      t.text :biography
      t.text :main_ideas
      t.text :personal_notes
      t.boolean :favorite, default: false, null: false
      t.timestamps
    end
  end
end
