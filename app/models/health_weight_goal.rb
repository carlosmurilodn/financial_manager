class HealthWeightGoal < ApplicationRecord
  GOAL_TYPES = %w[intermediate final].freeze

  belongs_to :user

  validates :target_weight, presence: true, numericality: { greater_than: 0, less_than: 1000 }
  validates :goal_type, presence: true, inclusion: { in: GOAL_TYPES }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { conditions: -> { where(goal_type: "final") }, if: :final? }
  validate :weights_have_valid_format

  scope :ordered, -> { order(:position, target_weight: :desc).order(:id) }
  scope :intermediate, -> { where(goal_type: "intermediate") }
  scope :final_goal, -> { where(goal_type: "final") }

  def intermediate?
    goal_type == "intermediate"
  end

  def final?
    goal_type == "final"
  end

  def kind_label
    final? ? "Meta final" : "Marco intermediário"
  end

  def reached_by?(weight_entry)
    weight_entry.present? && weight_entry.weight_kg <= target_weight
  end

  private

  def weights_have_valid_format
    raw_target = target_weight_before_type_cast
    target = raw_target.is_a?(BigDecimal) ? raw_target.to_s("F") : raw_target.to_s
    if target.present? && !valid_weight_format?(target)
      errors.add(:target_weight, "deve ter até duas casas decimais")
    end
  end

  def valid_weight_format?(value)
    value.match?(/\A\d+(?:\.\d{1,2})?\z/)
  end
end
