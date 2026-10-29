module Health
  class DailyDataMarkdownExport
    NUTRIENTS = { calories: ["Calorias", "kcal"], carbohydrates: ["Carboidratos", "g"],
      proteins: ["Proteínas", "g"], fats: ["Gorduras", "g"] }.freeze

    def initialize(user, date)
      @user = user
      @date = date
    end

    def path
      @date.strftime("%Y/%m/%Y-%m-%d.md")
    end

    def content
      weight = @user.weight_entries.find_by(measured_on: @date)
      meals = @user.nutrition_meals.includes(:nutrition_meal_items).where(occurred_on: @date).order(:id).to_a
      meals.sort_by! { |meal| [Nutrition::EnsureWeekMeals::DEFAULT_NAMES.index(meal.name) || 5, meal.id] }
      items = meals.flat_map { |meal| meal.nutrition_meal_items.to_a }
      sections = ["# Peso e alimentação · #{@date.strftime('%d/%m/%Y')}",
        "## Peso\n\n#{weight ? "#{number(weight.weight_kg)} kg" : 'Não informado'}",
        "## Totais do dia\n\n#{nutrients(items)}", "## Cardápio por refeição"]
      meals.each do |meal|
        meal_items = meal.nutrition_meal_items.sort_by(&:id)
        menu = meal_items.map do |item|
          "- #{text(item.name)}: #{number(item.quantity_grams)} #{item.quantity_unit}"
        end
        sections << "### #{text(meal.name)}\n\n#{menu.any? ? menu.join("\n") : 'Sem alimentos registrados.'}\n\n#{nutrients(meal_items)}"
      end
      sections << "Nenhuma refeição registrada." if meals.empty?
      sections.join("\n\n") + "\n"
    end

    private

    def nutrients(items)
      totals = Nutrition::MealSummary.totals(items)
      incomplete = Nutrition::MealSummary.incomplete_fields(items)
      NUTRIENTS.map do |field, (label, unit)|
        value = if totals[field].nil?
          "Não informado"
        else
          "#{number(totals[field])} #{unit}#{' (parcial; há valores não informados)' if incomplete.include?(field)}"
        end
        "- #{label}: #{value}"
      end.join("\n")
    end

    def number(value)
      ActiveSupport::NumberHelper.number_to_rounded(value, precision: 4, strip_insignificant_zeros: true,
        separator: ",", delimiter: "")
    end

    def text(value)
      ERB::Util.html_escape(value.to_s.gsub(/[\r\n]+/, " ")).gsub(/([\\`*\[\]_#|])/) { |character| "\\#{character}" }
    end
  end
end
