class HealthWeightGoal < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :target_weight, presence: true, numericality: { greater_than: 0, less_than: 1000 }
  validates :milestone_weights, length: { maximum: 10 }
  validate :weights_have_valid_format
  validate :milestones_are_intermediate

  def milestones_text
    return @milestones_text if defined?(@milestones_text)

    milestone_weights.map { |weight| weight.to_s("F").tr(".", ",") }.join("\n")
  end

  def milestones_text=(value)
    @milestones_text = value.to_s
    @raw_milestones = @milestones_text.split(/[;\r\n]+/).map(&:strip).reject(&:blank?).map { |weight| weight.tr(",", ".") }
    self.milestone_weights = @raw_milestones
  end

  def ordered_milestones
    milestone_weights.sort.reverse
  end

  private

  def weights_have_valid_format
    raw_target = target_weight_before_type_cast
    target = raw_target.is_a?(BigDecimal) ? raw_target.to_s("F") : raw_target.to_s
    if target.present? && !valid_weight_format?(target)
      errors.add(:target_weight, "deve ter até duas casas decimais")
    end
    if @raw_milestones&.any? { |weight| !valid_weight_format?(weight) }
      errors.add(:milestones_text, "devem ser números positivos com até duas casas decimais, um por linha")
    end
  end

  def valid_weight_format?(value)
    value.match?(/\A\d+(?:\.\d{1,2})?\z/)
  end

  def milestones_are_intermediate
    if milestone_weights.any? { |weight| weight.nil? || weight <= 0 || weight >= 1000 }
      errors.add(:milestones_text, "devem ser maiores que zero e menores que 1.000 kg")
    end
    if milestone_weights.uniq.size != milestone_weights.size
      errors.add(:milestones_text, "não podem se repetir")
    end
    if target_weight.present? && milestone_weights.compact.any? { |weight| weight <= target_weight }
      errors.add(:milestones_text, "devem ser maiores que o peso desejado")
    end
  end
end
