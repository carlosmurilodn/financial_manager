class ExerciseItem < ApplicationRecord
  TYPES = {
    "training" => "Musculação",
    "functional" => "Funcional",
    "ergometry" => "Ergometria"
  }.freeze
  INTENSITIES = {
    "Leve" => "light",
    "Moderada" => "moderate",
    "Intensa" => "intense"
  }.freeze

  belongs_to :exercise_entry, inverse_of: :exercise_items
  has_one :strength_exercise_log, dependent: :destroy, inverse_of: :exercise_item

  accepts_nested_attributes_for :strength_exercise_log, allow_destroy: true

  validates :exercise_type, presence: true, inclusion: { in: TYPES.keys }
  validates :duration_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 1440 }, allow_nil: true
  validates :steps, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :intensity, inclusion: { in: INTENSITIES.values }, allow_nil: true
  validates :notes, length: { maximum: 500 }
  validate :training_must_have_strength_log
  validate :ergometry_must_have_steps

  before_validation :normalize_optional_fields

  delegate :user, to: :exercise_entry

  def type_label
    TYPES.fetch(exercise_type, exercise_type)
  end

  def training?
    exercise_type == "training"
  end

  def functional?
    exercise_type == "functional"
  end

  def ergometry?
    exercise_type == "ergometry"
  end

  private

  def normalize_optional_fields
    self.intensity = intensity.presence
    self.notes = notes.to_s.strip.presence
  end

  def training_must_have_strength_log
    return unless training?
    return if strength_exercise_log.present? && !strength_exercise_log.marked_for_destruction?

    errors.add(:strength_exercise_log, "deve ser informado")
  end

  def ergometry_must_have_steps
    return unless ergometry?
    return if steps.present?

    errors.add(:steps, "deve ser informado")
  end
end
