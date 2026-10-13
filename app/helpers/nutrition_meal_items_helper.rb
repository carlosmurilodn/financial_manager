module NutritionMealItemsHelper
  def meal_item_nutrient_value(value)
    return "—" if value.nil?
    return taco_nutrient_value(value) if value.zero? || value.abs >= 0.01

    number_with_precision(value, precision: 8, strip_insignificant_zeros: true, separator: ",", delimiter: ".")
  end
end
