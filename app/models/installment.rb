class Installment < ApplicationRecord
  belongs_to :expense

  # Herdar atributos da despesa mãe (somente leitura)
  delegate :installments_count, :description, :category, :card, :payment_method, :balance_month, to: :expense

  # Validações
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :number, presence: true
  validates :due_date, presence: true

  # Escopos úteis
  scope :pending, -> { where(paid: false) }
  scope :paid, -> { where(paid: true) }
  scope :for_month, ->(month_date) { where(due_date: month_date.beginning_of_month..month_date.end_of_month) }

  def display_label
    "Parcela #{number}/#{installments_count}"
  end
end
