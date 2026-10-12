class TacoFood < TacoCatalogRecord
  scope :search_by_name, ->(query) {
    where("search_name LIKE ?", "%#{sanitize_sql_like(I18n.transliterate(query.to_s).downcase)}%") if query.present?
  }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def readonly?
    true
  end
end
