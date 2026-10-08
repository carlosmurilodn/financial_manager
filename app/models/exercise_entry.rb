class ExerciseEntry < ApplicationRecord
  belongs_to :user
  has_many :exercise_items, dependent: :destroy, inverse_of: :exercise_entry

  accepts_nested_attributes_for :exercise_items, allow_destroy: true, reject_if: :reject_exercise_item?

  validates :performed_on, presence: true
  validate :at_least_one_exercise_item

  scope :recent, -> { order(performed_on: :desc, created_at: :desc, id: :desc) }

  def total_duration_minutes
    exercise_items.sum { |item| item.duration_minutes.to_i }
  end

  def total_steps
    exercise_items.sum { |item| item.steps.to_i }
  end

  private

  def reject_exercise_item?(attributes)
    attributes["exercise_type"].blank?
  end

  def at_least_one_exercise_item
    return if exercise_items.reject(&:marked_for_destruction?).any?

    errors.add(:exercise_items, "deve ter pelo menos um exercício")
  end
end
