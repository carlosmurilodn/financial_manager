class WeeklyHealthGoalDay < ApplicationRecord
  DIET_STATUSES = { "Selecione" => "", "Segui a Dieta Totalmente" => "full", "Segui a Dieta Parcialmente" => "partial", "Não Segui a Dieta" => "none" }.freeze
  validates :diet_status, inclusion: { in: %w[full partial none] }, allow_nil: true
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
