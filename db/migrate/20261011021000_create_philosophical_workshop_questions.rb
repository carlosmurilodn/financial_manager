class CreatePhilosophicalWorkshopQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_questions do |t|
      t.references :user, null: false, foreign_key: true
      t.text :question, null: false
      t.text :context
      t.text :personal_reflection
      t.string :status, default: "investigating", null: false
      t.timestamps
    end

    add_check_constraint :philosophical_workshop_questions, "status IN ('investigating', 'provisionally_answered', 'archived')", name: "philosophical_workshop_questions_valid_status"
  end
end
