class PhilosophicalWorkshopPhilosopher < ApplicationRecord
  belongs_to :user
  has_many :concept_philosophers, class_name: "PhilosophicalWorkshopConceptPhilosopher", foreign_key: :philosopher_id, dependent: :destroy, inverse_of: :philosopher
  has_many :concepts, through: :concept_philosophers

  normalizes :name, with: ->(value) { value.to_s.strip }

  validates :name, presence: true, length: { maximum: 200 }
  validates :historical_period, :philosophical_school, length: { maximum: 200 }
  validates :favorite, inclusion: { in: [ true, false ] }
end
