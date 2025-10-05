class Card < ApplicationRecord
  has_many :expenses, dependent: :nullify

  validates :name, presence: true
  validates :number,
            allow_blank: true,
            format: { with: /\A\d{16}\z/, message: "deve conter exatamente 16 números" }

  # Novas validações
  validates :total_limit, :remaining_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :due_day, :best_day, inclusion: { in: 1..31 }, allow_nil: true

  def display_name
    base = if number.present?
            "#{name} (**** **** **** #{number[-4..-1]})"
          else
            name
          end

    if remaining_limit.present?
      "#{base} - Restante: R$ #{remaining_limit.to_f.round(2)}"
    else
      base
    end
  end
end
