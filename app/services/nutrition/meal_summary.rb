module Nutrition
  class MealSummary
    def self.totals(items)
      items = items.to_a
      NutritionMealItem::NUTRIENTS.index_with do |field|
        values = items.filter_map { |item| item.public_send(field) }
        values.sum if values.any?
      end
    end

    def self.incomplete_fields(items)
      items = items.to_a
      NutritionMealItem::NUTRIENTS.select do |field|
        items.any? { |item| item.public_send(field).nil? }
      end
    end
  end
end
