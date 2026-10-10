class PhilosophicalWorkshopInsight < ApplicationRecord
  STATUSES = {
    "captured" => "Capturado", "reflecting" => "Em reflexão",
    "developed" => "Desenvolvido", "archived" => "Arquivado"
  }.freeze

  belongs_to :user

  validates :content, presence: true
  validates :status, inclusion: { in: STATUSES.keys }

  def status_label
    STATUSES[status]
  end
end
