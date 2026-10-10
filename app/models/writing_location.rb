class WritingLocation < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[name kind description location physical_features atmosphere narrative_importance parent_location_id]

  has_many :writing_timeline_links, dependent: :destroy
  has_many :writing_narrative_associations, dependent: :destroy
  LABEL = "Locais"
  SINGULAR_LABEL = "Local"
  NAME_FIELD = :name
  FIELDS = { name: "Nome", kind: "Tipo", description: "Descrição", location: "Localização", physical_features: "Características físicas", atmosphere: "Atmosfera", narrative_importance: "Importância narrativa" }.freeze
  OPTIONS = { kind: { "city" => "Cidade", "district" => "Bairro", "building" => "Edifício", "residence" => "Residência", "natural" => "Ambiente natural", "region" => "Região", "country" => "País", "fictional" => "Local fictício", "other" => "Outro" } }.freeze
  include WritingNarrativeRecord
  validates :kind, inclusion: { in: OPTIONS[:kind].keys }, allow_blank: true
  PARENT_ASSOCIATION = :parent_location
  belongs_to :parent_location, class_name: "WritingLocation", optional: true
  has_many :children, class_name: "WritingLocation", foreign_key: :parent_location_id, dependent: :nullify
  include WritingHierarchy
  has_one_attached :reference_image
  has_many :writing_organizations, dependent: :nullify
  validate :valid_reference_image

  private

  def valid_reference_image
    return unless reference_image.attached?

    errors.add(:reference_image, "deve ser JPEG, PNG ou WebP") unless WritingCharacter::IMAGE_TYPES.include?(reference_image.blob.content_type)
    errors.add(:reference_image, "deve ter no máximo 5 MB") if reference_image.blob.byte_size > 5.megabytes
  end
end
