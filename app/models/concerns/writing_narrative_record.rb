module WritingNarrativeRecord
  extend ActiveSupport::Concern

  included do
    belongs_to :writing_book
    before_validation :normalize_narrative_title
    validates const_get(:NAME_FIELD), presence: true, length: { maximum: 200 }
  end

  def display_name
    public_send(self.class::NAME_FIELD)
  end

  private

  def normalize_narrative_title
    field = self.class::NAME_FIELD
    self[field] = self[field]&.strip
  end
end
