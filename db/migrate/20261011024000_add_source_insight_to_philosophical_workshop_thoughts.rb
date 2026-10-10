class AddSourceInsightToPhilosophicalWorkshopThoughts < ActiveRecord::Migration[8.0]
  def change
    add_reference :philosophical_workshop_thoughts, :source_insight,
      foreign_key: { to_table: :philosophical_workshop_insights, on_delete: :nullify },
      index: { name: "idx_philosophy_thoughts_source_insight" }
  end
end
