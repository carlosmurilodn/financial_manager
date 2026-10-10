class PhilosophicalWorkshopConcept < ApplicationRecord
  KINDS = { "concept" => "Conceito", "thesis" => "Tese" }.freeze

  belongs_to :user
  has_many :concept_philosophers, class_name: "PhilosophicalWorkshopConceptPhilosopher", foreign_key: :concept_id, dependent: :destroy, inverse_of: :concept
  has_many :philosophers, through: :concept_philosophers

  normalizes :title, with: ->(value) { value.to_s.strip }

  validates :title, presence: true, length: { maximum: 200 }
  validates :kind, presence: true, inclusion: { in: KINDS.keys }
  validates :description, presence: true

  def kind_label
    KINDS[kind]
  end
end
