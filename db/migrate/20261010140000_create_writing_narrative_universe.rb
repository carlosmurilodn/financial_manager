class CreateWritingNarrativeUniverse < ActiveRecord::Migration[8.0]
  def change
    create_table :writing_plots do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :kind
      t.string :status
      t.text :narrative_goal
      t.text :planned_development
      t.text :planned_outcome
      t.bigint :parent_plot_id
      t.timestamps
    end
    add_index :writing_plots, [ :id, :writing_book_id ], unique: true
    add_foreign_key :writing_plots, :writing_plots, column: [ :parent_plot_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_check_constraint :writing_plots, "parent_plot_id IS NULL OR parent_plot_id <> id", name: "writing_plots_not_self_parent"
    create_table :writing_conflicts do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :kind
      t.text :origin
      t.string :intensity
      t.string :status
      t.text :consequences
      t.text :planned_resolution
      t.timestamps
    end
    add_index :writing_conflicts, [ :id, :writing_book_id ], unique: true
    create_table :writing_locations do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind
      t.text :description
      t.text :location
      t.text :physical_features
      t.text :atmosphere
      t.text :narrative_importance
      t.bigint :parent_location_id
      t.timestamps
    end
    add_index :writing_locations, [ :id, :writing_book_id ], unique: true
    add_foreign_key :writing_locations, :writing_locations, column: [ :parent_location_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_check_constraint :writing_locations, "parent_location_id IS NULL OR parent_location_id <> id", name: "writing_locations_not_self_parent"
    create_table :writing_organizations do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind
      t.text :description
      t.text :history
      t.text :purpose
      t.text :structure
      t.text :notes
      t.bigint :writing_location_id
      t.timestamps
    end
    add_index :writing_organizations, [ :id, :writing_book_id ], unique: true
    add_foreign_key :writing_organizations, :writing_locations, column: [ :writing_location_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    create_table :writing_universe_rules do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category
      t.text :description
      t.text :limitations
      t.text :exceptions
      t.text :narrative_consequences
      t.text :notes
      t.timestamps
    end
    add_index :writing_universe_rules, [ :id, :writing_book_id ], unique: true
    create_table :writing_plot_characters do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.references :writing_plot, null: false
      t.references :writing_character, null: false
      t.timestamps
    end
    add_index :writing_plot_characters, [ :writing_plot_id, :writing_character_id ], unique: true, name: "idx_plot_character_unique"
    add_foreign_key :writing_plot_characters, :writing_plots, column: [ :writing_plot_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_foreign_key :writing_plot_characters, :writing_characters, column: [ :writing_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    create_table :writing_conflict_characters do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.references :writing_conflict, null: false
      t.references :writing_character, null: false
      t.timestamps
    end
    add_index :writing_conflict_characters, [ :writing_conflict_id, :writing_character_id ], unique: true, name: "idx_conflict_character_unique"
    add_foreign_key :writing_conflict_characters, :writing_conflicts, column: [ :writing_conflict_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_foreign_key :writing_conflict_characters, :writing_characters, column: [ :writing_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    create_table :writing_conflict_plots do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.references :writing_conflict, null: false
      t.references :writing_plot, null: false
      t.timestamps
    end
    add_index :writing_conflict_plots, [ :writing_conflict_id, :writing_plot_id ], unique: true, name: "idx_conflict_plot_unique"
    add_foreign_key :writing_conflict_plots, :writing_conflicts, column: [ :writing_conflict_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_foreign_key :writing_conflict_plots, :writing_plots, column: [ :writing_plot_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    create_table :writing_organization_memberships do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.references :writing_organization, null: false
      t.references :writing_character, null: false
      t.string :role
      t.timestamps
    end
    add_index :writing_organization_memberships, [ :writing_organization_id, :writing_character_id ], unique: true, name: "idx_organization_membership_unique"
    add_foreign_key :writing_organization_memberships, :writing_organizations, column: [ :writing_organization_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_foreign_key :writing_organization_memberships, :writing_characters, column: [ :writing_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
  end
end
