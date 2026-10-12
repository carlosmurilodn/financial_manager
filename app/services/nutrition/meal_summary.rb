module Nutrition
  class MealSummary
    def self.totals(items)
      items = items.to_a
      NutritionMealItem::NUTRIENTS.index_with do |field|
        values = items.map { |item| item.public_send(field) }
        values.sum if values.any? && values.none?(&:nil?)
      end
    end
  end
end
