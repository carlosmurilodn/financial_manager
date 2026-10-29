class WeightEntry < ApplicationRecord
  include HealthDataGithubTracking
  belongs_to :user

  validates :measured_on, presence: true, uniqueness: { scope: :user_id, message: "já possui uma medição. Edite o registro existente." }
  validates :weight_kg, presence: true, numericality: { greater_than: 0, less_than: 1000 }
  validate :measurement_not_in_future
  validate :weight_format

  scope :recent, -> { order(measured_on: :desc) }

  private

  def health_data_github_coordinates
    coordinates = [[user_id, measured_on]]
    if saved_change_to_measured_on? || saved_change_to_user_id?
      coordinates << [user_id_before_last_save || user_id, measured_on_before_last_save]
    end
    coordinates.select { |_, date| date }.group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
  end

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
