class Income < ApplicationRecord
    validates :amount, numericality: { greater_than: 0 }
    validates :date, :balance_month, presence: true

    attribute :paid, :boolean, default: true
end
