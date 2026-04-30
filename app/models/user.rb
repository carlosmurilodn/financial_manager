class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable

  has_many :passkey_credentials, dependent: :destroy
end
