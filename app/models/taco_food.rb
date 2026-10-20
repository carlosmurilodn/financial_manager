class TacoFood < TacoCatalogRecord
  scope :search_by_name, ->(query) {
    terms = I18n.transliterate(query.to_s).downcase.split(/[\s,]+/)
    terms.reduce(all) do |foods, term|
      foods.where("search_name LIKE ?", "%#{sanitize_sql_like(term)}%")
    end
  }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def readonly?
    true
  end
end
