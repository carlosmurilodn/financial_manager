class CreatePhilosophicalWorkshopThoughtQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_thought_questions do |t|
      t.references :thought, null: false, foreign_key: { to_table: :philosophical_workshop_thoughts }, index: false
      t.references :question, null: false, foreign_key: { to_table: :philosophical_workshop_questions }, index: { name: "idx_philosophy_thought_questions_question" }
      t.timestamps
    end

    add_index :philosophical_workshop_thought_questions, [ :thought_id, :question_id ], unique: true, name: "idx_philosophy_thought_questions_unique_pair"
  end
end
