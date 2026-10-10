class CreatePhilosophicalWorkshopConceptPhilosophers < ActiveRecord::Migration[8.0]
  def change
    create_table :philosophical_workshop_concept_philosophers do |t|
      t.references :concept, null: false, foreign_key: { to_table: :philosophical_workshop_concepts }, index: false
      t.references :philosopher, null: false, foreign_key: { to_table: :philosophical_workshop_philosophers }, index: { name: "idx_philosophy_links_philosopher" }
      t.timestamps
    end

    add_index :philosophical_workshop_concept_philosophers, [ :concept_id, :philosopher_id ], unique: true, name: "idx_philosophy_links_unique_pair"
  end
end
