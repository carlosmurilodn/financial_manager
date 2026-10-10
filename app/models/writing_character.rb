class WritingCharacter < ApplicationRecord
  ROLES = { "protagonist" => "Protagonista", "antagonist" => "Antagonista", "supporting" => "Coadjuvante", "secondary" => "Secundário", "extra" => "Figurante", "other" => "Outro" }.freeze
  STATUSES = { "active" => "Ativo", "inactive" => "Inativo", "deceased" => "Falecido", "missing" => "Desaparecido", "undefined" => "Indefinido" }.freeze
  IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  PROFILE_SECTIONS = {
    "Características físicas" => { age: "Idade", appearance: "Aparência", height: "Altura", distinguishing_features: "Características marcantes", usual_clothing: "Vestimentas habituais" },
    "Personalidade" => { personality: "Personalidade", virtues: "Virtudes", flaws: "Defeitos", fears: "Medos", desires: "Desejos", motivations: "Motivações", beliefs: "Crenças", internal_contradictions: "Contradições internas" },
    "História pessoal" => { origin: "Origem", past: "Passado", family: "Família", education: "Formação", profession: "Profissão", secrets: "Segredos" },
    "Desenvolvimento narrativo" => { goals: "Objetivos", internal_needs: "Necessidades internas", conflicts: "Conflitos", initial_situation: "Situação inicial", planned_transformations: "Transformações previstas", planned_outcome: "Desfecho planejado" }
  }.freeze

  belongs_to :writing_book
  has_one_attached :reference_image
  has_many :outgoing_relationships, class_name: "WritingRelationship", foreign_key: :source_character_id, dependent: :destroy, inverse_of: :source_character
  has_many :incoming_relationships, class_name: "WritingRelationship", foreign_key: :target_character_id, dependent: :destroy, inverse_of: :target_character

  before_validation :normalize_identification
  validates :name, presence: true, length: { maximum: 200 }
  validates :surname, :nicknames, length: { maximum: 200 }
  validates :role, inclusion: { in: ROLES.keys }, allow_blank: true
  validates :status, inclusion: { in: STATUSES.keys }, allow_blank: true
  validate :valid_reference_image

  def full_name
    [ name, surname ].compact_blank.join(" ")
  end

  def role_label
    ROLES[role] || "Não informado"
  end

  def status_label
    STATUSES[status] || "Não informado"
  end

  def relationships
    writing_book.writing_relationships.where("source_character_id = :id OR target_character_id = :id", id: id)
  end

  private

  def normalize_identification
    %i[name surname nicknames].each { |field| self[field] = self[field]&.strip }
  end

  def valid_reference_image
    return unless reference_image.attached?

    errors.add(:reference_image, "deve ser JPEG, PNG ou WebP") unless IMAGE_TYPES.include?(reference_image.blob.content_type)
    errors.add(:reference_image, "deve ter no máximo 5 MB") if reference_image.blob.byte_size > 5.megabytes
  end
end
