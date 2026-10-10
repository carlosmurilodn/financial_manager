module WritingNarrativeContextsHelper
  def writing_context_path(book, document)
    return "" unless document.persisted?

    key = document.is_a?(WritingScene) ? :scene_id : :chapter_id
    writing_book_writing_narrative_context_path(book, key => document.id)
  end
end
