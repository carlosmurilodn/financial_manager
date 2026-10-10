class PhilosophicalWorkshopQuestion < ApplicationRecord
  STATUSES = {
    "investigating" => "Em investigação",
    "provisionally_answered" => "Respondida provisoriamente",
    "archived" => "Arquivada"
  }.freeze

  belongs_to :user

  normalizes :question, with: ->(value) { value.to_s.strip }

  validates :question, presence: true
  validates :status, inclusion: { in: STATUSES.keys }

  def status_label
    STATUSES[status]
  end
end
