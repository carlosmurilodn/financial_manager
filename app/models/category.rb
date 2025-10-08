class Category < ApplicationRecord
  has_many :expenses, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  # Método para exibir emoji + nome
  def display_name
    "#{emoji} #{name}".strip
  end

  # Método opcional para ordenar apenas pelo nome, ignorando emoji
  def sort_name
    name.downcase
  end
end
