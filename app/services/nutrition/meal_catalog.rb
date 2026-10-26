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
          external_foods = TabNutClient.new.search(name)
          if source == "all"
            external_foods = external_foods.reject { |food| food[:data_source].to_s.match?(/\btaco\b/i) }
          end
          foods.concat(external_foods)
        rescue TabNutClient::Unavailable => error
          raise if source == "tabnut"

          @warning = error.message
        end
      end
      foods
    end

    attr_reader :warning

    def history(meal_name:)
      recent_items = NutritionMealItem.joins(:nutrition_meal)
        .where(nutrition_meals: { user_id: @user.id, name: meal_name })
        .group(:source, :source_id)
        .order(Arel.sql("MAX(COALESCE(nutrition_meal_items.last_added_at, nutrition_meal_items.created_at)) DESC, MAX(nutrition_meal_items.id) DESC"))
        .limit(20).pluck(:source, :source_id)

      recent_items.filter_map do |source, id|
        find(source: source, id: id)
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end

    def find(source:, id:)
      if source == "tabnut"
        saved = NutritionMealItem.joins(:nutrition_meal)
          .where(nutrition_meals: { user_id: @user.id }, source: source, source_id: id.to_s)
          .order(updated_at: :desc, id: :desc).first
        if saved&.food_snapshot.present?
          return { id: id.to_s, source: source, name: saved.name,
            nutrients: saved.nutrients_per_100.symbolize_keys, quantity_unit: saved.quantity_unit,
            food_snapshot: saved.food_snapshot, data_source: saved.food_snapshot["data_source"] }
        end
        return TabNutClient.new.find(id.to_s)
      end

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
