module WritingBookLink
  extend ActiveSupport::Concern

  included do
    before_validation :assign_link_book
    validate :same_narrative_book
  end

  private

  def assign_link_book
    owner = public_send(self.class::LINK_ASSOCIATIONS.first)
    self.writing_book = owner.writing_book if owner
  end

  def same_narrative_book
    self.class::LINK_ASSOCIATIONS.each do |association|
      record = public_send(association)
      errors.add(association, "deve pertencer ao mesmo livro") if record && record.writing_book_id != writing_book_id
    end
  end
end
