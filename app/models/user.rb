class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable
  has_many :expenses, dependent: :destroy
  has_many :financial_goals, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :weight_entries, dependent: :destroy
  has_many :weekly_health_plans, dependent: :destroy
  has_many :weekly_health_reviews, dependent: :destroy
  has_many :health_wins, dependent: :destroy
  has_many :passkey_credentials, dependent: :destroy
end
