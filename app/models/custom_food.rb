class CustomFood < ApplicationRecord
  NUTRIENTS = %i[calories carbohydrates proteins fats fiber].freeze

  belongs_to :user

  validates :name, :category, presence: true
  validates(*NUTRIENTS, numericality: { greater_than_or_equal_to: 0, less_than: 100_000_000 }, allow_nil: true)

  scope :search_by_name, ->(query) {
    where("name ILIKE ?", "%#{sanitize_sql_like(query.to_s)}%") if query.present?
  }
  scope :by_category, ->(category) { where(category: category) if category.present? }
end
