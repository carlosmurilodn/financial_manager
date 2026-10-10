class IntegrateWritingNarrativeAndNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :writing_chapters, :position, :integer, default: 0, null: false
    add_index :writing_chapters, [ :id, :writing_book_id ], unique: true
    create_table :writing_scenes do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.bigint :writing_chapter_id, null: false
      t.string :title, null: false
      t.jsonb :content, null: false, default: { type: "doc", content: [ { type: "paragraph", attrs: { firstLineIndent: true, textAlign: "left" } } ] }
      t.integer :document_version, default: 1, null: false
      t.integer :lock_version, default: 0, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :writing_scenes, [ :id, :writing_book_id ], unique: true
    add_index :writing_scenes, [ :writing_chapter_id, :position ]
    add_foreign_key :writing_scenes, :writing_chapters, column: [ :writing_chapter_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    create_table :writing_notes do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :category
      t.string :status
      t.timestamps
    end
    add_index :writing_notes, [ :id, :writing_book_id ], unique: true
    create_table :writing_narrative_associations do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.bigint :writing_chapter_id
      t.bigint :writing_scene_id
      t.bigint :writing_character_id
      t.bigint :writing_plot_id
      t.bigint :writing_conflict_id
      t.bigint :writing_location_id
      t.bigint :writing_organization_id
      t.timestamps
    end
    add_check_constraint :writing_narrative_associations, "num_nonnulls(writing_chapter_id,writing_scene_id) = 1", name: "narrative_association_one_owner"
    add_check_constraint :writing_narrative_associations, "num_nonnulls(writing_character_id,writing_plot_id,writing_conflict_id,writing_location_id,writing_organization_id) = 1", name: "narrative_association_one_element"
    add_foreign_key :writing_narrative_associations, :writing_chapters, column: [ :writing_chapter_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_chapter_id
    add_foreign_key :writing_narrative_associations, :writing_scenes, column: [ :writing_scene_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_scene_id
    add_foreign_key :writing_narrative_associations, :writing_characters, column: [ :writing_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_character_id
    add_foreign_key :writing_narrative_associations, :writing_plots, column: [ :writing_plot_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_plot_id
    add_foreign_key :writing_narrative_associations, :writing_conflicts, column: [ :writing_conflict_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_conflict_id
    add_foreign_key :writing_narrative_associations, :writing_locations, column: [ :writing_location_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_location_id
    add_foreign_key :writing_narrative_associations, :writing_organizations, column: [ :writing_organization_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_narrative_associations, :writing_organization_id
    add_index :writing_narrative_associations, [ :writing_chapter_id, :writing_character_id ], unique: true, where: "writing_chapter_id IS NOT NULL AND writing_character_id IS NOT NULL", name: "idx_narrative_chapter_character"
    add_index :writing_narrative_associations, [ :writing_chapter_id, :writing_plot_id ], unique: true, where: "writing_chapter_id IS NOT NULL AND writing_plot_id IS NOT NULL", name: "idx_narrative_chapter_plot"
    add_index :writing_narrative_associations, [ :writing_chapter_id, :writing_conflict_id ], unique: true, where: "writing_chapter_id IS NOT NULL AND writing_conflict_id IS NOT NULL", name: "idx_narrative_chapter_conflict"
    add_index :writing_narrative_associations, [ :writing_chapter_id, :writing_location_id ], unique: true, where: "writing_chapter_id IS NOT NULL AND writing_location_id IS NOT NULL", name: "idx_narrative_chapter_location"
    add_index :writing_narrative_associations, [ :writing_chapter_id, :writing_organization_id ], unique: true, where: "writing_chapter_id IS NOT NULL AND writing_organization_id IS NOT NULL", name: "idx_narrative_chapter_organization"
    add_index :writing_narrative_associations, [ :writing_scene_id, :writing_character_id ], unique: true, where: "writing_scene_id IS NOT NULL AND writing_character_id IS NOT NULL", name: "idx_narrative_scene_character"
    add_index :writing_narrative_associations, [ :writing_scene_id, :writing_plot_id ], unique: true, where: "writing_scene_id IS NOT NULL AND writing_plot_id IS NOT NULL", name: "idx_narrative_scene_plot"
    add_index :writing_narrative_associations, [ :writing_scene_id, :writing_conflict_id ], unique: true, where: "writing_scene_id IS NOT NULL AND writing_conflict_id IS NOT NULL", name: "idx_narrative_scene_conflict"
    add_index :writing_narrative_associations, [ :writing_scene_id, :writing_location_id ], unique: true, where: "writing_scene_id IS NOT NULL AND writing_location_id IS NOT NULL", name: "idx_narrative_scene_location"
    add_index :writing_narrative_associations, [ :writing_scene_id, :writing_organization_id ], unique: true, where: "writing_scene_id IS NOT NULL AND writing_organization_id IS NOT NULL", name: "idx_narrative_scene_organization"
    create_table :writing_note_links do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.bigint :writing_note_id, null: false
      t.bigint :writing_character_id
      t.bigint :writing_plot_id
      t.bigint :writing_conflict_id
      t.bigint :writing_chapter_id
      t.bigint :writing_scene_id
      t.timestamps
    end
    add_check_constraint :writing_note_links, "num_nonnulls(writing_character_id,writing_plot_id,writing_conflict_id,writing_chapter_id,writing_scene_id) = 1", name: "note_link_one_target"
    add_foreign_key :writing_note_links, :writing_notes, column: [ :writing_note_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_foreign_key :writing_note_links, :writing_characters, column: [ :writing_character_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_note_links, [ :writing_note_id, :writing_character_id ], unique: true, where: "writing_character_id IS NOT NULL", name: "idx_note_link_character"
    add_index :writing_note_links, :writing_character_id
    add_foreign_key :writing_note_links, :writing_plots, column: [ :writing_plot_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_note_links, [ :writing_note_id, :writing_plot_id ], unique: true, where: "writing_plot_id IS NOT NULL", name: "idx_note_link_plot"
    add_index :writing_note_links, :writing_plot_id
    add_foreign_key :writing_note_links, :writing_conflicts, column: [ :writing_conflict_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_note_links, [ :writing_note_id, :writing_conflict_id ], unique: true, where: "writing_conflict_id IS NOT NULL", name: "idx_note_link_conflict"
    add_index :writing_note_links, :writing_conflict_id
    add_foreign_key :writing_note_links, :writing_chapters, column: [ :writing_chapter_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_note_links, [ :writing_note_id, :writing_chapter_id ], unique: true, where: "writing_chapter_id IS NOT NULL", name: "idx_note_link_chapter"
    add_index :writing_note_links, :writing_chapter_id
    add_foreign_key :writing_note_links, :writing_scenes, column: [ :writing_scene_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ]
    add_index :writing_note_links, [ :writing_note_id, :writing_scene_id ], unique: true, where: "writing_scene_id IS NOT NULL", name: "idx_note_link_scene"
    add_index :writing_note_links, :writing_scene_id
  end
end
