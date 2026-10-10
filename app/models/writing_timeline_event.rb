class WritingTimelineEvent < ApplicationRecord
  LABEL = "Linha do Tempo"
  SINGULAR_LABEL = "Acontecimento"
  NAME_FIELD = :title
  FIELDS = { title: "Título", description: "Descrição", kind: "Tipo", status: "Situação", date_mode: "Definição temporal", temporal_reference: "Referência temporal" }.freeze
  OPTIONS = {
    kind: { "main" => "Principal", "secondary" => "Secundário", "historical" => "Histórico", "flashback" => "Flashback", "flashforward" => "Flashforward", "other" => "Outro" },
    status: { "planned" => "Planejado", "confirmed" => "Confirmado", "discarded" => "Descartado" },
    date_mode: { "undefined" => "Sem definição", "exact" => "Data exata", "approximate" => "Data aproximada", "relative" => "Referência relativa" }
  }.freeze
  include WritingNarrativeRecord
  belongs_to :reference_event, class_name: "WritingTimelineEvent", optional: true
  has_many :referencing_events, class_name: "WritingTimelineEvent", foreign_key: :reference_event_id, dependent: :nullify
  has_many :writing_timeline_links, dependent: :destroy
  OPTIONS.each { |field, options| validates field, inclusion: { in: options.keys } }
  validates :temporal_reference, length: { maximum: 200 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :occurred_on, presence: true, if: -> { date_mode == "exact" }
  validates :temporal_reference, presence: true, if: -> { date_mode.in?(%w[approximate relative]) }
  before_validation :normalize_temporal_fields
  validate :valid_reference_chain

  scope :manual_order, -> { order(:position, :created_at, :id) }

  private

  def normalize_temporal_fields
    self.temporal_reference = temporal_reference&.strip
    self.occurred_on = nil unless date_mode == "exact"
    self.reference_event_id = nil unless date_mode == "relative"
    self.temporal_reference = nil if date_mode.in?(%w[exact undefined])
  end

  def valid_reference_chain
    return if reference_event_id.blank? || writing_book.nil?

    parents = writing_book.writing_timeline_events.pluck(:id, :reference_event_id).to_h
    unless parents.key?(reference_event_id)
      errors.add(:reference_event, "deve pertencer ao mesmo livro")
      return
    end
    visited = [ id ].compact
    cursor = reference_event_id
    while cursor
      if visited.include?(cursor)
        errors.add(:reference_event, "não pode formar uma referência temporal circular")
        break
      end
      visited << cursor
      cursor = parents[cursor]
    end
  end
end
