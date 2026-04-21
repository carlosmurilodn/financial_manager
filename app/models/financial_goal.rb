class FinancialGoal < ApplicationRecord
  STATUS_LABELS = {
    "planned" => "Planejado",
    "in_progress" => "Em andamento",
    "completed" => "Concluido",
    "paused" => "Pausado"
  }.freeze

  PRIORITY_LABELS = {
    "low" => "Baixa",
    "medium" => "Media",
    "high" => "Alta"
  }.freeze

  enum :status, {
    planned: 0,
    in_progress: 1,
    completed: 2,
    paused: 3
  }, prefix: true

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2
  }, prefix: true

  validates :description, :due_date, :status, :priority, presence: true
  validates :target_amount, numericality: { greater_than: 0 }
  validates :current_amount, numericality: { greater_than_or_equal_to: 0 }

  def status_label
    STATUS_LABELS.fetch(status, status.to_s.humanize)
  end

  def priority_label
    PRIORITY_LABELS.fetch(priority, priority.to_s.humanize)
  end

  def remaining_amount
    [target_amount.to_d - current_amount.to_d, 0.to_d].max
  end

  def progress_percent
    return 0 if target_amount.to_d <= 0

    ((current_amount.to_d / target_amount.to_d) * 100).clamp(0, 100).to_f
  end

  def months_until_due(reference_date = Date.current)
    return 0 if due_date.blank? || due_date <= reference_date

    ((due_date.year * 12) + due_date.month) - ((reference_date.year * 12) + reference_date.month) + 1
  end

  def monthly_required_amount(reference_date = Date.current)
    months = months_until_due(reference_date)
    return remaining_amount if months <= 1

    remaining_amount / months
  end
end
