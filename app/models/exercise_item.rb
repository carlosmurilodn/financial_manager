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
  has_many :strength_exercise_logs, dependent: :destroy, inverse_of: :exercise_item

  accepts_nested_attributes_for :strength_exercise_logs, allow_destroy: true, reject_if: :reject_strength_exercise_log?

  validates :exercise_type, presence: true, inclusion: { in: TYPES.keys }
  validates :duration_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 1440 }, allow_nil: true
  validates :intensity, inclusion: { in: INTENSITIES.values }, allow_nil: true
  validates :notes, length: { maximum: 500 }
  validate :training_must_have_strength_log

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
    return if strength_exercise_logs.reject(&:marked_for_destruction?).any?

    errors.add(:strength_exercise_logs, "deve ter pelo menos um exercício de musculação")
  end

  def reject_strength_exercise_log?(attributes)
    attributes["muscle_group_id"].blank? && attributes["strength_exercise_catalog_id"].blank? && attributes["sets"].blank?
  end
end
