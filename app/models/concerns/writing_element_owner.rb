module WritingElementOwner
  extend ActiveSupport::Concern

  included do
    has_many :writing_narrative_associations, dependent: :destroy
    has_many :writing_note_links, dependent: :destroy
  end

  def narrative_owner_attributes
    { self.class.model_name.singular.to_sym => self }
  end

  def related_notes
    ids = writing_note_links.pluck(:writing_note_id)
    narrative_ids = writing_narrative_associations.pluck(:writing_character_id, :writing_plot_id, :writing_conflict_id)
    targets = %i[writing_character_id writing_plot_id writing_conflict_id]
    conditions = targets.each_with_index.filter_map do |field, index|
      element_ids = narrative_ids.filter_map { |row| row[index] }.uniq
      WritingNoteLink.arel_table[field].in(element_ids) if element_ids.any?
    end
    if conditions.any?
      ids.concat(writing_book.writing_note_links.where(conditions.reduce(&:or)).pluck(:writing_note_id))
    end
    writing_book.writing_notes.where(id: ids.uniq)
  end
end
