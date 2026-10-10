class WritingOrganization < ApplicationRecord
  has_many :writing_narrative_associations, dependent: :destroy
  LABEL = "Organizações"
  SINGULAR_LABEL = "Organização"
  NAME_FIELD = :name
  FIELDS = { name: "Nome", kind: "Tipo", description: "Descrição", history: "História", purpose: "Finalidade", structure: "Estrutura", notes: "Observações" }.freeze
  OPTIONS = {}.freeze
  include WritingNarrativeRecord
  belongs_to :writing_location, optional: true
  has_many :writing_organization_memberships, dependent: :destroy
  has_many :writing_characters, through: :writing_organization_memberships
  accepts_nested_attributes_for :writing_organization_memberships, allow_destroy: true
  validate :location_from_same_book

  private

  def location_from_same_book
    errors.add(:writing_location, "deve pertencer ao mesmo livro") if writing_location && writing_location.writing_book_id != writing_book_id
  end
end
