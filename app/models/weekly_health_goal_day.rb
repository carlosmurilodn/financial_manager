class WeeklyHealthGoalDay < ApplicationRecord
  DIET_STATUSES = { "Selecione" => "", "Segui a Dieta Totalmente" => "full", "Segui a Dieta Parcialmente" => "partial", "Não Segui a Dieta" => "none" }.freeze
  validates :diet_status, inclusion: { in: %w[full partial none] }, allow_nil: true
  EXERCISE_STATUSES = { "Selecione" => "", "Realizado" => "completed", "Não Realizado" => "not_completed" }.freeze
  EXERCISE_INTENSITIES = { "Selecione" => "", "Leve" => "light", "Moderada" => "moderate", "Intensa" => "intense" }.freeze
  EXERCISE_FOCUSES = { "Selecione" => "", "Força" => "strength", "Resistência" => "endurance", "Mobilidade" => "mobility", "Misto" => "mixed" }.freeze

  validates :exercise_status, inclusion: { in: EXERCISE_STATUSES.values }, allow_nil: true
  validates :exercise_intensity, inclusion: { in: EXERCISE_INTENSITIES.values.reject(&:blank?) }, allow_nil: true
  validates :exercise_focus, inclusion: { in: EXERCISE_FOCUSES.values.reject(&:blank?) }, allow_nil: true
  validates :duration_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 1440 }, allow_nil: true
  validates :distance_km, numericality: { greater_than: 0, less_than: 10000 }, allow_nil: true
  validates :steps, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :muscle_groups, length: { maximum: 150 }
  validates :exercise_notes, length: { maximum: 500 }

  def exercise_day_status
    return "completed" if completed?
    return "not_completed" if persisted? && exercise_status != ""

    ""
  end

  def walking_pace
    return unless completed? && duration_minutes&.positive? && distance_km&.positive?

    seconds = (duration_minutes / distance_km * 60).round
    format("%d:%02d", seconds / 60, seconds % 60)
  end

  belongs_to :weekly_health_goal

  validates :occurred_on, presence: true, uniqueness: { scope: :weekly_health_goal_id }
  validate :occurred_on_within_plan_week

  scope :completed, -> { where(completed: true) }

  private

  def occurred_on_within_plan_week
    return if occurred_on.blank? || weekly_health_goal.blank?

    week_start = weekly_health_goal.weekly_health_plan.week_start
    return if occurred_on.between?(week_start, week_start + 6.days)

    errors.add(:occurred_on, "deve estar dentro da semana da meta")
  end
end
