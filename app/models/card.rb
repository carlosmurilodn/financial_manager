class Card < ApplicationRecord
  has_many :expenses, dependent: :nullify
  has_one_attached :icon

  before_validation :normalize_number
  before_save :normalize_currency_values

  validates :name, presence: true
  validates :number,
            allow_blank: true,
            format: { with: /\A\d{16}\z/, message: "deve conter exatamente 16 números" }

  validates :total_limit, :remaining_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :due_day, :best_day, inclusion: { in: 1..31 }, allow_nil: true

  def display_name
    base = if number.present?
            "#{name} (**** **** **** #{number[-4..-1]})"
          else
            name
          end

    if remaining_limit.present?
      "#{base} - Restante: R$ #{'%.2f' % remaining_limit}"
    else
      base
    end
  end

  private

  def normalize_number
    self.number = number.gsub(/\D/, "") if number.present?
  end

  def normalize_currency_values
    self.total_limit = parse_brazilian_currency(total_limit)
    self.remaining_limit = parse_brazilian_currency(remaining_limit)
  end

  def parse_brazilian_currency(value)
    return value if value.is_a?(Numeric)
    return nil if value.blank?

    value.to_s
         .gsub(/[^\d,]/, "") # remove R$, espaços etc.
         .gsub(".", "")      # remove pontos (milhar)
         .gsub(",", ".")     # troca vírgula por ponto (decimal)
         .to_f
  end
end
