module Nutrition
  class MealCatalog
    def initialize(user)
      @user = user
    end

    def search(name:, source:)
      return [] if name.blank?

      catalogs = { "taco" => TacoFood.all, "custom" => @user.custom_foods, "recipe" => @user.nutrition_recipes.includes(:nutrition_recipe_ingredients) }
      catalogs.select! { |key, _| key == source } unless source == "all"
      foods = catalogs.flat_map do |origin, catalog|
        catalog.search_by_name(name).order(:name, :id).limit(10).map { |record| describe(record, origin) }
      end.sort_by { |food| [ I18n.transliterate(food[:name]).downcase, food[:source], food[:id] ] }
      if %w[all tabnut].include?(source)
        begin
          foods.concat(TabNutClient.new.search(name))
        rescue TabNutClient::Unavailable => error
          raise if source == "tabnut"

          @warning = error.message
        end
      end
      foods
    end

    attr_reader :warning

    def find(source:, id:)
      return TabNutClient.new.find(id.to_s) if source == "tabnut"

      record = case source
      when "taco" then TacoFood.find(id)
      when "custom" then @user.custom_foods.find(id)
      when "recipe" then @user.nutrition_recipes.includes(:nutrition_recipe_ingredients).find(id)
      else raise ArgumentError, "Origem inválida."
      end
      describe(record, source)
    end

    private

    def describe(record, source)
      nutrients = if source == "recipe"
        RecipeCalculator.new(record).totals.fetch(:per_100g)
      else
        NutritionMealItem::NUTRIENTS.index_with { |field| record.public_send(field) }
      end
      portion_grams = RecipeCalculator.new(record).portion_weight_grams if source == "recipe"
      { id: record.id, source: source, name: record.name, nutrients: nutrients, portion_grams: portion_grams }
    end
  end
end
