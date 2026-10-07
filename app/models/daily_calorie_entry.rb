class DailyCalorieEntry < ApplicationRecord
  CALCULATION_STATUSES = %w[calculated missing_consumption missing_profile missing_weight invalid_profile].freeze

  belongs_to :user

  validates :occurred_on, presence: true, uniqueness: { scope: :user_id }
  validates :consumed_calories, numericality: { greater_than_or_equal_to: 0, less_than: 10_000_000_000 }, allow_nil: true
  validates :calculation_status, inclusion: { in: CALCULATION_STATUSES }
  validate :consumption_format

  scope :chronological, -> { order(:occurred_on) }
  scope :calculated, -> { where(calculation_status: "calculated") }

  def future_estimate?
    occurred_on.present? && occurred_on > Date.current
  end

  private

  def consumption_format
    value = consumed_calories_before_type_cast.to_s
    return if value.blank? || value.match?(/\A\d+(?:\.\d{1,2})?\z/)

    errors.add(:consumed_calories, "deve ser um número não negativo com até duas casas decimais")
  end
end
