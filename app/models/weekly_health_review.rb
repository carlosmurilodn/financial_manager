class WeeklyHealthReview < ApplicationRecord
  QUESTIONS = {
    worked_well: "O que funcionou esta semana?",
    obstacles: "O que atrapalhou?",
    within_control: "Isso estava sob meu controle?",
    next_adjustments: "Existe alguma mudança útil para a próxima semana?",
    minimum_goal: "Qual é a meta mínima da próxima semana?"
  }.freeze

  belongs_to :user

  validates :week_start, presence: true, uniqueness: { scope: :user_id }
  validates(*QUESTIONS.keys, length: { maximum: 2000 })
  validate :week_starts_on_monday
  validate :at_least_one_answer

  def answered_count
    QUESTIONS.keys.count { |attribute| public_send(attribute).present? }
  end

  def complete?
    answered_count == QUESTIONS.size
  end

  private

  def week_starts_on_monday
    if week_start.present? && !week_start.monday?
      errors.add(:week_start, "deve ser uma segunda-feira")
    end
  end

  def at_least_one_answer
    errors.add(:base, "Preencha pelo menos uma resposta para salvar a revisão.") if answered_count.zero?
  end
end
