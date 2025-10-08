class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :card, optional: true
  has_many :installments, dependent: :destroy

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

  # Campos do parcelamento
  # attr_accessor :installments_count, :current_installment, :is_parent

  after_create :generate_future_installments, if: -> { payment_method_credito_parcelado? && is_parent }

  # Gera as parcelas futuras a partir da parcela atual
  def generate_future_installments
    return unless installments_count.present? && current_installment.present?

    remaining = installments_count.to_i - current_installment.to_i
    return if remaining <= 0

    remaining.times do |i|
      number = current_installment.to_i + i + 1
      due = date >> (i + 1) # adiciona i+1 meses à data da parcela atual
      next_balance_month = balance_month.to_date >> (i + 1)

      installments.create!(
        number: number,
        amount: amount,
        due_date: due,
        paid: false,
        balance_month: next_balance_month
      )
    end
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
end
