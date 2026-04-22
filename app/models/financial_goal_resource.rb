class FinancialGoalResource < ApplicationRecord
  RESOURCE_TYPE_LABELS = {
    "own_resource" => "Recurso proprio",
    "external_resource" => "Recurso externo",
    "credit_limit" => "Limite de credito"
  }.freeze

  belongs_to :financial_goal
  belongs_to :source, polymorphic: true, optional: true

  before_validation :clear_source_unless_credit_limit
  before_validation :set_card_resource_defaults

  enum :resource_type, {
    own_resource: 0,
    external_resource: 1,
    credit_limit: 2
  }, prefix: true

  validates :description, :resource_type, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def resource_type_label
    RESOURCE_TYPE_LABELS.fetch(resource_type, resource_type.to_s.humanize)
  end

  def own_or_external?
    resource_type_own_resource? || resource_type_external_resource?
  end

  def effective_amount
    return source.remaining_limit.to_d if card_limit_resource?

    amount.to_d
  end

  def card_limit_resource?
    resource_type_credit_limit? && source.is_a?(Card)
  end

  private

  def clear_source_unless_credit_limit
    return if resource_type_credit_limit?

    self.source = nil
  end

  def set_card_resource_defaults
    return unless card_limit_resource?

    self.description = source.display_name if description.blank?
    self.amount = source.remaining_limit
  end
end
