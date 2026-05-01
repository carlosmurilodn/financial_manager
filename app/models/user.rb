class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable
  has_many :expenses, dependent: :destroy
  has_many :financial_goal, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :passkey_credentials, dependent: :destroy
end
