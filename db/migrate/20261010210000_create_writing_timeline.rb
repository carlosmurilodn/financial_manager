class CreateWritingTimeline < ActiveRecord::Migration[8.0]
  TARGETS = %i[writing_character writing_location writing_plot writing_conflict writing_chapter writing_scene].freeze

  def change
    create_table :writing_timeline_events do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :kind, null: false, default: "main"
      t.string :status, null: false, default: "planned"
      t.string :date_mode, null: false, default: "undefined"
      t.date :occurred_on
      t.time :occurred_at
      t.string :temporal_reference
      t.bigint :reference_event_id
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :writing_timeline_events, [ :id, :writing_book_id ], unique: true
    add_index :writing_timeline_events, [ :writing_book_id, :occurred_on, :position ], name: "idx_timeline_chronology"
    add_index :writing_timeline_events, :reference_event_id
    add_foreign_key :writing_timeline_events, :writing_timeline_events,
      column: [ :reference_event_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ], name: "fk_timeline_reference_book"
    add_check_constraint :writing_timeline_events, "reference_event_id IS NULL OR reference_event_id <> id", name: "timeline_no_self_reference"
    add_check_constraint :writing_timeline_events,
      "(date_mode = 'exact' AND occurred_on IS NOT NULL AND reference_event_id IS NULL) OR (date_mode IN ('approximate','relative','undefined') AND occurred_on IS NULL AND (date_mode = 'relative' OR reference_event_id IS NULL))",
      name: "timeline_valid_date"
    create_table :writing_timeline_links do |t|
      t.references :writing_book, null: false, foreign_key: true
      t.bigint :writing_timeline_event_id, null: false
      TARGETS.each { |target| t.bigint "#{target}_id" }
      t.timestamps
    end
    columns = TARGETS.map { |target| "#{target}_id" }.join(",")
    add_check_constraint :writing_timeline_links, "num_nonnulls(#{columns}) = 1", name: "timeline_link_one_target"
    add_index :writing_timeline_links, :writing_timeline_event_id, name: "idx_timeline_links_event"
    add_foreign_key :writing_timeline_links, :writing_timeline_events,
      column: [ :writing_timeline_event_id, :writing_book_id ], primary_key: [ :id, :writing_book_id ], name: "fk_timeline_link_event_book"
    reversible do |direction|
      direction.up do
        execute "ALTER TABLE writing_timeline_events ENABLE ROW LEVEL SECURITY"
        execute "ALTER TABLE writing_timeline_links ENABLE ROW LEVEL SECURITY"
      end
    end
    TARGETS.each do |target|
      field = "#{target}_id"
      suffix = target.to_s.delete_prefix("writing_")
      add_index :writing_timeline_links, field
      add_index :writing_timeline_links, [ :writing_timeline_event_id, field ], unique: true,
        where: "#{field} IS NOT NULL", name: "idx_timeline_link_#{suffix}"
      add_foreign_key :writing_timeline_links, target.to_s.pluralize,
        column: [ field, :writing_book_id ], primary_key: [ :id, :writing_book_id ], name: "fk_timeline_link_#{suffix}_book"
    end
  end
end
