class WritingNarrativeAssociation < ApplicationRecord
  OWNERS = %i[writing_chapter writing_scene].freeze
  ELEMENTS = %i[writing_character writing_plot writing_conflict writing_location writing_organization].freeze
  belongs_to :writing_book
  (OWNERS + ELEMENTS).each { |association| belongs_to association, optional: true }
  validate :valid_association

  private

  def valid_association
    owners = OWNERS.select { |association| public_send("#{association}_id").present? }
    elements = ELEMENTS.select { |association| public_send("#{association}_id").present? }
    errors.add(:base, "Selecione um capítulo ou cena e um elemento narrativo.") unless owners.size == 1 && elements.size == 1
    (owners + elements).each do |association|
      record = public_send(association)
      errors.add(association, "deve pertencer ao mesmo livro") unless record && record.writing_book_id == writing_book_id
    end
    if owners.size == 1 && elements.size == 1
      keys = (owners + elements).index_with { |association| public_send(association) }
      errors.add(:base, "Elemento já associado.") if self.class.where(keys).where.not(id: id).exists?
    end
  end
end
