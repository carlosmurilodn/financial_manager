class WritingNoteLink < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[writing_note_id writing_character_id writing_plot_id writing_conflict_id writing_chapter_id writing_scene_id]

  TARGETS = %i[writing_character writing_plot writing_conflict writing_chapter writing_scene].freeze
  belongs_to :writing_book
  belongs_to :writing_note
  TARGETS.each { |association| belongs_to association, optional: true }
  validate :valid_note_link

  private

  def valid_note_link
    targets = TARGETS.select { |association| public_send("#{association}_id").present? }
    errors.add(:base, "Selecione exatamente um vínculo para a nota.") unless targets.size == 1
    ([ :writing_note ] + targets).each do |association|
      record = public_send(association)
      errors.add(association, "deve pertencer ao mesmo livro") unless record && record.writing_book_id == writing_book_id
    end
    if targets.size == 1
      field = "#{targets.first}_id"
      existing = self.class.where(writing_note_id: writing_note_id).where(self.class.arel_table[field].eq(public_send(field)))
      errors.add(:base, "Vínculo já cadastrado.") if existing.where.not(id: id).exists?
    end
  end
end
