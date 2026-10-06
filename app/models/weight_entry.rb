class WeightEntry < ApplicationRecord
  belongs_to :user

  validates :measured_on, presence: true, uniqueness: { scope: :user_id, message: "já possui uma medição. Edite o registro existente." }
  validates :weight_kg, presence: true, numericality: { greater_than: 0, less_than: 1000 }
  validate :measurement_not_in_future
  validate :weight_format

  scope :recent, -> { order(measured_on: :desc) }

  private

  def weight_format
    value = weight_kg_before_type_cast.to_s
    if value.present? && !value.match?(/\A\d+(?:\.\d{1,2})?\z/)
      errors.add(:weight_kg, "deve ser um número positivo com até duas casas decimais")
    end
  end

  def measurement_not_in_future
    if measured_on.present? && measured_on > Date.current
      errors.add(:measured_on, "não pode ser futura")
    end
  end
end
