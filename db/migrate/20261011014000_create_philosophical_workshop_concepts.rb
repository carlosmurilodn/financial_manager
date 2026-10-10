class CreatePhilosophicalWorkshopConcepts < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_concepts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :kind, null: false
      t.text :description, null: false
      t.text :premises
      t.text :arguments
      t.text :personal_notes
      t.timestamps
    end

    add_check_constraint :philosophical_workshop_concepts, "kind IN ('concept', 'thesis')", name: "philosophical_workshop_concepts_valid_kind"
  end
end
