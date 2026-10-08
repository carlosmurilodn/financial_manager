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

  TEXT_FIELDS = (HealthDiaryContent::WEEKLY.keys + QUESTIONS.keys + %i[notes other_need]).uniq.freeze
  belongs_to :user
  validates(*HealthDiaryContent::METRICS.keys, numericality: { only_integer: true, in: 1..5 }, allow_nil: true)
  validates(*TEXT_FIELDS, length: { maximum: 2000 })
  validates :scenario, inclusion: { in: HealthDiaryContent::SCENARIOS.keys }, allow_blank: true
  validate :valid_needs

  def reflection_prompts
    daily? ? HealthDiaryContent::DAILY : HealthDiaryContent::WEEKLY
  end

  def needs=(values)
    super(values.is_a?(Array) ? values.reject(&:blank?).uniq : values)
  end

  def valid_needs
    errors.add(:needs, "contém opções inválidas") unless needs.is_a?(Array) && (needs - HealthDiaryContent::NEEDS).empty?
  end

  validates :review_kind, presence: true, inclusion: { in: REVIEW_KINDS.keys.map(&:to_s) }
  validates :week_start, presence: true, uniqueness: { scope: %i[user_id review_kind] }
  validate :week_starts_on_monday
  validate :at_least_one_answer

  def answered_count
    reflection_prompts.keys.count { |attribute| public_send(attribute).present? }
  end

  def complete?
    answered_count == reflection_prompts.size
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
    return "Período inválido" if week_start.blank?

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
    has_content = TEXT_FIELDS.any? { |attribute| public_send(attribute).present? } || HealthDiaryContent::METRICS.keys.any? { |attribute| public_send(attribute).present? } || needs.present?
    errors.add(:base, "Registre um indicador, uma resposta ou uma necessidade para salvar.") unless has_content
  end
end
