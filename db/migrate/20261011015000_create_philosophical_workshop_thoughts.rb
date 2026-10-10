class CreatePhilosophicalWorkshopThoughts < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_thoughts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :central_idea, null: false
      t.text :supporting_arguments
      t.text :counterpoints
      t.text :provisional_conclusion
      t.string :kind, default: "reflection", null: false
      t.string :status, default: "developing", null: false
      t.timestamps
    end

    add_check_constraint :philosophical_workshop_thoughts, "kind IN ('reflection', 'hypothesis', 'conviction')", name: "philosophical_workshop_thoughts_valid_kind"
    add_check_constraint :philosophical_workshop_thoughts, "status IN ('developing', 'consolidated', 'revision')", name: "philosophical_workshop_thoughts_valid_status"
  end
end
