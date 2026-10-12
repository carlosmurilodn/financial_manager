module NutritionMealResponses
  private

  def day_summary_payload(date)
    meals = current_user.nutrition_meals.includes(:nutrition_meal_items).where(occurred_on: date).to_a
    items = meals.flat_map { |meal| meal.nutrition_meal_items.to_a }
    calories = Nutrition::MealSummary.totals(items)[:calories]
    {
      tab_calories: items.empty? ? "Sem registro" : (calories.nil? ? "— kcal" : "#{helpers.taco_nutrient_value(calories)} kcal"),
      day_html: render_to_string(partial: "nutrition_meals/day_summary", formats: [ :html ], locals: { meals: meals }),
      has_meals: meals.any?
    }
  end

  def item_summary_payload(meal)
    meal.nutrition_meal_items.reload
    {
      html: render_to_string(partial: "nutrition_meals/items", formats: [ :html ], locals: { meal: meal, context: "card" }),
      picker_html: render_to_string(partial: "nutrition_meals/items", formats: [ :html ], locals: { meal: meal, context: "picker" })
    }.merge(day_summary_payload(meal.occurred_on))
  end
end
