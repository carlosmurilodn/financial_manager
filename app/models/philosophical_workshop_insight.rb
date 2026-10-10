class PhilosophicalWorkshopInsight < ApplicationRecord
  STATUSES = {
    "captured" => "Capturado", "reflecting" => "Em reflexão",
    "developed" => "Desenvolvido", "archived" => "Arquivado"
  }.freeze

  belongs_to :user
  has_many :derived_thoughts, class_name: "PhilosophicalWorkshopThought", foreign_key: :source_insight_id, dependent: :nullify, inverse_of: :source_insight

  validates :content, presence: true
  validates :status, inclusion: { in: STATUSES.keys }

  def status_label
    STATUSES[status]
  end
end
