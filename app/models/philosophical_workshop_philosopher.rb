class PhilosophicalWorkshopPhilosopher < ApplicationRecord
  belongs_to :user

  normalizes :name, with: ->(value) { value.to_s.strip }

  validates :name, presence: true, length: { maximum: 200 }
  validates :historical_period, :philosophical_school, length: { maximum: 200 }
  validates :favorite, inclusion: { in: [ true, false ] }
end
