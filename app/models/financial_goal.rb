class FinancialGoal < ApplicationRecord
  belongs_to :category, optional: true

  has_many :financial_goal_resources, dependent: :destroy
  accepts_nested_attributes_for :financial_goal_resources, allow_destroy: true, reject_if: :blank_resource?

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
    [target_amount.to_d - progress_amount, 0.to_d].max
  end

  def progress_percent
    return 0 if target_amount.to_d <= 0

    ((progress_amount / target_amount.to_d) * 100).clamp(0, 100).to_f
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

  def own_resources_amount
    included_resources.select(&:own_or_external?).sum(&:effective_amount)
  end

  def credit_limit_amount
    included_resources.select(&:resource_type_credit_limit?).sum(&:effective_amount)
  end

  def potential_amount
    own_resources_amount + credit_limit_amount
  end

  def progress_amount
    has_included_resources? ? own_resources_amount : current_amount.to_d
  end

  def has_included_resources?
    included_resources.any?
  end

  private

  def included_resources
    financial_goal_resources.reject(&:marked_for_destruction?).select(&:include_in_total?)
  end

  def blank_resource?(attributes)
    amount_digits = attributes["amount"].to_s.gsub(/\D/, "")

    attributes["description"].blank? && amount_digits.to_i.zero? && attributes["source_id"].blank?
  end
end
