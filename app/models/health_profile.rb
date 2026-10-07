class HealthProfile < ApplicationRecord
  FORMULA_SEXES = { "Masculino" => "male", "Feminino" => "female" }.freeze

  belongs_to :user

  validates :user_id, uniqueness: true
  validates :height_cm, presence: true, numericality: { greater_than: 0, less_than: 1000 }
  validates :birth_date, presence: true
  validates :formula_sex, inclusion: { in: FORMULA_SEXES.values }
  validate :birth_date_not_in_future
  validate :height_format

  private

  def birth_date_not_in_future
    return if birth_date.blank? || birth_date <= Date.current

    errors.add(:birth_date, "não pode ser futura")
  end

  def height_format
    value = height_cm_before_type_cast.to_s
    return if value.blank? || value.match?(/\A\d+(?:\.\d{1,2})?\z/)

    errors.add(:height_cm, "deve ser um número positivo com até duas casas decimais")
  end
end
