module WritingHierarchy
  extend ActiveSupport::Concern

  included do
    validate :valid_narrative_parent
    around_save :serialize_narrative_hierarchy
  end

  private

  def valid_narrative_parent
    parent = public_send(self.class::PARENT_ASSOCIATION)
    seen = [ id ].compact
    while parent
      if parent.writing_book_id != writing_book_id
        errors.add(self.class::PARENT_ASSOCIATION, "deve pertencer ao mesmo livro")
        break
      end
      if seen.include?(parent.id)
        errors.add(self.class::PARENT_ASSOCIATION, "não pode criar uma hierarquia circular")
        break
      end
      seen << parent.id
      parent = parent.public_send(self.class::PARENT_ASSOCIATION)
    end
  end

  def serialize_narrative_hierarchy
    writing_book.with_lock do
      association(self.class::PARENT_ASSOCIATION).reset
      valid_narrative_parent
      raise ActiveRecord::RecordInvalid, self if errors.any?

      yield
    end
  end
end
