class WeeklyHealthReview < ApplicationRecord
  REVIEW_KINDS = {
    daily: "Diário",
    weekly: "Semanal"
  }.freeze

  MONTH_NAMES = %w[
    janeiro
    fevereiro
    março
    abril
    maio
    junho
    julho
    agosto
    setembro
    outubro
    novembro
    dezembro
  ].freeze

  QUESTIONS = {
    worked_well: "O que funcionou esta semana?",
    obstacles: "O que atrapalhou?",
    within_control: "Isso estava sob meu controle?",
    next_adjustments: "Existe alguma mudança útil para a próxima semana?",
    minimum_goal: "Qual é a meta mínima da próxima semana?"
  }.freeze

  DAILY_QUESTIONS = {
    worked_well: "O que funcionou neste dia?",
    obstacles: "O que atrapalhou neste dia?",
    within_control: "Isso estava sob meu controle neste dia?",
    next_adjustments: "Existe alguma mudança útil para o próximo dia?",
    minimum_goal: "Qual é a meta mínima do próximo dia?"
  }.freeze

  belongs_to :user

  validates :review_kind, presence: true, inclusion: { in: REVIEW_KINDS.keys.map(&:to_s) }
  validates :week_start, presence: true, uniqueness: { scope: %i[user_id review_kind] }
  validates(*QUESTIONS.keys, length: { maximum: 2000 })
  validate :week_starts_on_monday
  validate :at_least_one_answer

  def answered_count
    QUESTIONS.keys.count { |attribute| public_send(attribute).present? }
  end

  def complete?
    answered_count == QUESTIONS.size
  end

  def daily?
    review_kind == "daily"
  end

  def questions
    daily? ? DAILY_QUESTIONS : QUESTIONS
  end

  def weekly?
    review_kind == "weekly"
  end

  def period_end
    weekly? ? week_start + 6.days : week_start
  end

  def period_title
    if weekly?
      "Semana de #{week_start.strftime("%d/%m/%Y")} a #{period_end.strftime("%d/%m/%Y")}"
    else
      "Dia #{week_start.day} de #{MONTH_NAMES[week_start.month - 1]} de #{week_start.year}"
    end
  end

  private

  def week_starts_on_monday
    if weekly? && week_start.present? && !week_start.monday?
      errors.add(:week_start, "deve ser uma segunda-feira")
    end
  end

  def at_least_one_answer
    errors.add(:base, "Preencha pelo menos uma resposta para salvar a revisão.") if answered_count.zero?
  end
end
