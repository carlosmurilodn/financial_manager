class Card < ApplicationRecord
  has_many :expenses, dependent: :nullify
  has_one_attached :icon

  before_validation :normalize_number
  before_save :normalize_currency_values

  validates :name, presence: true
  validates :number,
            allow_blank: true,
            format: { with: /\A\d{16}\z/, message: "deve conter exatamente 16 números" }

  # 🔹 Remove validação de remaining_limit (pois agora é calculado)
  validates :total_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :due_day, :best_day, inclusion: { in: 1..31 }, allow_nil: true

  # 🔹 Novo método calculado
  def remaining_limit
    total_limit.to_f - unpaid_total
  end

  def display_name
    base = if number.present?
      "#{name} (**** **** **** #{number[-4..-1]})"
    else
      name
    end

    "#{base} - Restante: #{ActionController::Base.helpers.number_to_currency(remaining_limit, unit: 'R$ ', separator: ',', delimiter: '.')}"
  end

  private

  def unpaid_total
    # soma despesas e parcelas não pagas
    unpaid_expenses = expenses.where(paid: false).sum(:amount)

    unpaid_installments = Installment.joins(:expense)
                                     .where(paid: false, expenses: { card_id: id })
                                     .sum(:amount)

    unpaid_expenses + unpaid_installments
  end

  def normalize_number
    self.number = number.gsub(/\D/, "") if number.present?
  end

  def normalize_currency_values
    self.total_limit = parse_brazilian_currency(total_limit)
  end

  def parse_brazilian_currency(value)
    return value if value.is_a?(Numeric)
    return nil if value.blank?

    value.to_s
         .gsub(/[^\d,]/, "")
         .gsub(".", "")
         .gsub(",", ".")
         .to_f
  end
end
