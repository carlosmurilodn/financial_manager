class Income < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validates :date, :balance_month, presence: true

  attribute :paid, :boolean, default: true
  attr_accessor :repetir
end
