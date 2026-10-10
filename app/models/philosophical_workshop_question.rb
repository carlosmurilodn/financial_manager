class PhilosophicalWorkshopQuestion < ApplicationRecord
  STATUSES = {
    "investigating" => "Em investigação",
    "provisionally_answered" => "Respondida provisoriamente",
    "archived" => "Arquivada"
  }.freeze

  belongs_to :user
  has_many :thought_questions, class_name: "PhilosophicalWorkshopThoughtQuestion", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :thoughts, through: :thought_questions

  normalizes :question, with: ->(value) { value.to_s.strip }

  validates :question, presence: true
  validates :status, inclusion: { in: STATUSES.keys }

  def status_label
    STATUSES[status]
  end
end
