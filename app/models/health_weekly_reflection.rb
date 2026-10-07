class HealthWeeklyReflection < ApplicationRecord
  include HealthPersonalRecord
  TEXT_FIELDS = (Health::SelfKnowledgeContent::WEEKLY.keys - [:weekly_needs] + [:weekly_needs_notes]).freeze
  METRIC_FIELDS = [:routine_satisfaction].freeze
  NEEDS_FIELD = :weekly_needs
  validates :week_start, presence: true, uniqueness: { scope: :user_id }
  validates :routine_satisfaction, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates(*TEXT_FIELDS, length: { maximum: 2000 })
  validate :monday_start

  def weekly_needs=(values)
    super(values.is_a?(Array) ? values.reject(&:blank?).uniq : values)
  end

  def reference_date
    week_start
  end

  def monday_start
    errors.add(:week_start, "deve ser uma segunda-feira") if week_start && !week_start.monday?
  end
end
