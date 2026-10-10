class CreateWritingCharactersAndRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :writing_characters do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :name, null: false
      t.string :surname
      t.string :nicknames
      t.string :role
      t.string :status
      t.text :age
      t.text :appearance
      t.text :height
      t.text :distinguishing_features
      t.text :usual_clothing
      t.text :personality
      t.text :virtues
      t.text :flaws
      t.text :fears
      t.text :desires
      t.text :motivations
      t.text :beliefs
      t.text :internal_contradictions
      t.text :origin
      t.text :past
      t.text :family
      t.text :education
      t.text :profession
      t.text :secrets
      t.text :goals
      t.text :internal_needs
      t.text :conflicts
      t.text :initial_situation
      t.text :planned_transformations
      t.text :planned_outcome
      t.timestamps
    end
    add_index :writing_characters, [ :id, :writing_book_id ], unique: true
    create_table :writing_relationships do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.bigint :source_character_id, null: false
      t.bigint :target_character_id, null: false
      t.string :relation_type, null: false
      t.text :description
      t.text :current_situation
      t.string :fingerprint, null: false
      t.timestamps
    end
    add_index :writing_relationships, [ :writing_book_id, :fingerprint ], unique: true
    add_index :writing_relationships, :source_character_id
    add_index :writing_relationships, :target_character_id
    add_foreign_key :writing_relationships, :writing_characters, column: [ :source_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ], name: "fk_writing_relationship_source_book"
    add_foreign_key :writing_relationships, :writing_characters, column: [ :target_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ], name: "fk_writing_relationship_target_book"
    add_check_constraint :writing_relationships, "source_character_id <> target_character_id", name: "writing_relationship_different_characters"
  end
end
