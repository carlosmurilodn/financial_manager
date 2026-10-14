require "csv"

module Nutrition
  class MealItemDetails
    GROUPS = {
      "Composição e energia" => {
        calories: ["Calorias", "kcal", "energia_kcal"], energy_kj: ["Energia", "kJ", "energia_kj"],
        carbohydrates: ["Carboidratos", "g", "carboidrato_g"], proteins: ["Proteínas", "g", "proteina_g"],
        fats: ["Gorduras", "g", "lipideos_g"], fiber: ["Fibras", "g", "fibra_g"],
        cholesterol: ["Colesterol", "mg", "colesterol_mg"], moisture: ["Umidade", "g", "umidade_pct"],
        ash: ["Cinzas", "g", "cinzas_g"]
      },
      "Minerais" => {
        calcium: ["Cálcio", "mg", "calcio_mg"], magnesium: ["Magnésio", "mg", "magnesio_mg"],
        manganese: ["Manganês", "mg", "manganes_mg"], phosphorus: ["Fósforo", "mg", "fosforo_mg"],
        iron: ["Ferro", "mg", "ferro_mg"], sodium: ["Sódio", "mg", "sodio_mg"],
        potassium: ["Potássio", "mg", "potassio_mg"], copper: ["Cobre", "mg", "cobre_mg"], zinc: ["Zinco", "mg", "zinco_mg"]
      },
      "Vitaminas" => {
        retinol: ["Retinol", "µg", "retinol_mcg"], retinol_equivalent: ["Vitamina A (RE)", "µg", "RE_mcg"],
        retinol_activity: ["Vitamina A (RAE)", "µg", "RAE_mcg"], thiamine: ["Tiamina (B1)", "mg", "tiamina_mg"],
        riboflavin: ["Riboflavina (B2)", "mg", "riboflavina_mg"], pyridoxine: ["Piridoxina (B6)", "mg", "piridoxina_mg"],
        niacin: ["Niacina (B3)", "mg", "niacina_mg"], vitamin_c: ["Vitamina C", "mg", "vitamina_c_mg"]
      }
    }.freeze

    def initialize(item)
      @item = item
      @user = item.nutrition_meal.user
    end

    def nutrients
      base = if @item.source == "tabnut"
        @item.food_snapshot.fetch("per_100g", {}).symbolize_keys.transform_values { |value| decimal(value) }
      else
        composition(@item.source, @item.source_id)
      end
      values = base&.transform_values { |value| value * @item.quantity_grams / 100 if value } || {}
      values.merge(NutritionMealItem::NUTRIENTS.index_with { |field| @item.public_send(field) })
    end

    private

    def composition(source, id)
      case source
      when "taco"
        row = taco_rows[id.to_s]
        return unless row

        GROUPS.values.reduce({}, :merge).transform_values { |(_, _, column)| decimal(row[column]) }
      when "custom"
        food = @user.custom_foods.find_by(id: id)
        CustomFood::NUTRIENTS.index_with { |field| food.public_send(field) } if food
      when "recipe"
        recipe = @user.nutrition_recipes.includes(:nutrition_recipe_ingredients).find_by(id: id)
        recipe_composition(recipe) if recipe
      end
    end

    def recipe_composition(recipe)
      return unless recipe.final_weight_grams&.positive?

      ingredients = recipe.nutrition_recipe_ingredients.map do |ingredient|
        values = composition(ingredient.source, ingredient.source_id) || {}
        values.merge(NutritionRecipeIngredient::NUTRIENTS.index_with { |field| ingredient.public_send(field) })
          .transform_values { |value| value * ingredient.quantity_grams / recipe.final_weight_grams if value }
      end
      GROUPS.values.reduce({}, :merge).keys.index_with do |field|
        amounts = ingredients.map { |values| values[field] }
        amounts.sum if amounts.any? && amounts.none?(&:nil?)
      end
    end

    def taco_rows
      @taco_rows ||= begin
        path = Rails.root.join("db/catalog/data/taco_composicao.csv")
        Rails.cache.fetch(["nutrition-taco-composition", File.mtime(path).to_f]) do
          CSV.read(path, headers: true, encoding: "bom|utf-8").each_with_object({}) do |row, rows|
            rows[row["numero_alimento"]] = row.to_h
          end
        end
      end
    end

    def decimal(value)
      return if value.blank? || %w[NaN NA N/A NULL].include?(value)

      number = BigDecimal(value)
      number if number.finite?
    end
  end
end
