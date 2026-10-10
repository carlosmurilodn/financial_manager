class WritingNotesController < WritingNarrativeController
  private

  def narrative_model
    WritingNote
  end

  def record_params
    attributes = super
    raw_links = params.require(:writing_note).permit(links: WritingNoteLink::TARGETS.to_h { |association| [ association, [] ] })[:links]
    return attributes unless raw_links

    @note_targets = raw_links.to_h.flat_map do |association, ids|
      ids.reject(&:blank?).map(&:to_i).uniq.map { |id| [ association.to_sym, @book.public_send(association.pluralize).find(id) ] }
    end
    attributes
  end

  def after_narrative_save
    return unless @note_targets

    Writing::SyncLinks.new(@book, @record.writing_note_links, WritingNoteLink::TARGETS).call(@note_targets)
  end
end
