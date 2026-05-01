class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :card, optional: true
  belongs_to :user


  enum :payment_method, {
    pix: 0,
    debito: 1,
    credito_a_vista: 2,
    credito_parcelado: 3,
    dinheiro: 4
  }, prefix: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, :balance_month, :category_id, :payment_method, presence: true
  validates :card_id, presence: true, if: -> { payment_method_credito_a_vista? || payment_method_credito_parcelado? }
  validates :description, presence: true
  validates :installments_count,
            :current_installment,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            if: :payment_method_credito_parcelado?
  validate :current_installment_cannot_exceed_total_installments

  after_create :generate_future_installment_expenses, if: :should_generate_future_installment_expenses?

  attr_accessor :repetir

  before_validation :set_default_repetir, unless: -> { repetir.present? }
  before_validation :set_default_installment_values
  before_save :sync_paid_at, if: -> { has_attribute?(:paid_at) }

  def installment_label
    return "Unica" unless payment_method_credito_parcelado?

    "#{current_installment}/#{installments_count}"
  end

  def parcelled_group_root?
    payment_method_credito_parcelado? && installment_group_id.present? && installment_group_id == id
  end

  def sync_future_group_expenses!
    return unless payment_method_credito_parcelado? && installment_group_id.present?

    future_group_expenses.find_each do |expense|
      month_offset = expense.current_installment - current_installment

      expense.update!(
        description: description,
        amount: amount,
        category: category,
        card: card,
        payment_method: payment_method,
        installments_count: installments_count,
        date: date,
        balance_month: balance_month >> month_offset
      )
    end
  end

  def destroy_from_current_onward!
    return destroy! unless payment_method_credito_parcelado? && installment_group_id.present?

    self.class.where(installment_group_id: installment_group_id)
              .where("current_installment >= ?", current_installment)
              .destroy_all
  end

  def toggle_paid_from_current_onward!
    return update!(paid: !paid) unless payment_method_credito_parcelado? && installment_group_id.present?

    target_paid = !paid
    paid_at = target_paid ? Time.current : nil

    self.class.where(installment_group_id: installment_group_id)
              .where("current_installment >= ?", current_installment)
              .update_all(paid: target_paid, paid_at: paid_at, updated_at: Time.current)
  end

  def self.payment_method_names
    {
      "credito_a_vista" => "Crédito à Vista",
      "credito_parcelado" => "Crédito Parcelado",
      "pix" => "PIX",
      "debito" => "Débito",
      "dinheiro" => "Dinheiro"
    }
  end

  private

  def future_group_expenses
    self.class.where(installment_group_id: installment_group_id)
              .where.not(id: id)
              .where("current_installment > ?", current_installment)
  end

  def generate_future_installment_expenses
    update_column(:installment_group_id, id)

    remaining = installments_count.to_i - current_installment.to_i

    remaining.times do |i|
      next_installment = current_installment.to_i + i + 1

      self.class.create!(
        installment_group_id: id,
        description: description,
        category: category,
        card: card,
        payment_method: payment_method,
        amount: amount,
        date: date,
        balance_month: balance_month.to_date >> (i + 1),
        installments_count: installments_count,
        current_installment: next_installment,
        paid: false,
        repetir: 0
      )
    end
  end

  def set_default_repetir
    self.repetir = 0 if repetir.blank?
  end

  def set_default_installment_values
    self.installments_count = 1 if installments_count.blank?
    self.current_installment = 1 if current_installment.blank?
  end

  def should_generate_future_installment_expenses?
    payment_method_credito_parcelado? && installment_group_id.blank?
  end

  def sync_paid_at
    self.paid_at = Time.current if paid? && paid_at.blank?
    self.paid_at = nil unless paid?
  end

  def current_installment_cannot_exceed_total_installments
    return unless payment_method_credito_parcelado?
    return if current_installment.blank? || installments_count.blank?
    return unless current_installment.to_i > installments_count.to_i

    errors.add(:current_installment, "não pode ser maior que o total de parcelas")
  end
end
