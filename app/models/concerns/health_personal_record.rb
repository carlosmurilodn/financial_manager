module HealthPersonalRecord
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    validate :some_content
    validate :allowed_needs
    scope :recent, -> { order(created_at: :desc) }
  end

  def selected_needs
    public_send(self.class::NEEDS_FIELD)
  end

  def allowed_needs
    values = selected_needs
    errors.add(self.class::NEEDS_FIELD, "contém opções inválidas") unless values.is_a?(Array) && (values - Health::SelfKnowledgeContent::NEEDS).empty?
  end

  def some_content
    filled = self.class::TEXT_FIELDS.any? { |field| public_send(field).present? } || self.class::METRIC_FIELDS.any? { |field| public_send(field).present? } || selected_needs.present? || legacy_content.present?
    errors.add(:base, "Preencha um indicador, uma resposta ou uma necessidade para salvar.") unless filled
  end

  def to_param
    reference_date.iso8601
  end
end
