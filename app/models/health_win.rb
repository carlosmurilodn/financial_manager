class HealthWin < ApplicationRecord
  SUGGESTIONS = [
    "Voltar a treinar mesmo sem vontade",
    "Preparar marmitas",
    "Caminhar em um dia difícil",
    "Fazer escolha planejada com fome",
    "Não abandonar depois de oscilação no peso"
  ].freeze

  belongs_to :user

  validates :achieved_on, presence: true
  validates :description, presence: true, length: { maximum: 500 }
  validate :achievement_not_in_future

  scope :recent, -> { order(achieved_on: :desc, id: :desc) }

  private

  def achievement_not_in_future
    if achieved_on.present? && achieved_on > Date.current
      errors.add(:achieved_on, "não pode ser futura")
    end
  end
end
