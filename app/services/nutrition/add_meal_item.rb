module Nutrition
  class AddMealItem
    def initialize(meal:, source:, source_id:, request_token:, quantity_grams: nil, quantity: nil, unit: "grams")
      @meal = meal
      @source = source.to_s
      @source_id = source_id.to_s
      @quantity = BigDecimal((quantity || quantity_grams).to_s)
      @unit = unit.to_s
      @token = request_token.to_s
    rescue ArgumentError
      raise ArgumentError, "Informe uma quantidade válida."
    end

    def call
      raise ArgumentError, "Informe uma quantidade positiva com até quatro casas decimais." unless @quantity.finite? && @quantity.positive? && @quantity < 100_000_000 && @quantity == @quantity.round(4)
      raise ArgumentError, "Unidade inválida." unless %w[grams servings].include?(@unit)
      raise ArgumentError, "Somente receitas podem ser registradas em porções." if @unit == "servings" && @source != "recipe"
      raise ArgumentError, "Identificador de inclusão inválido." unless @token.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

      @meal.with_lock do
        previous = @meal.nutrition_meal_items.where("addition_tokens @> ?::jsonb", [ @token ].to_json).first
        next previous if previous

        saved = @meal.nutrition_meal_items.find_by(source: @source, source_id: @source_id) if @source == "tabnut"
        food = if saved&.food_snapshot.present?
          { id: saved.source_id, name: saved.name, nutrients: saved.food_snapshot.fetch("per_100g").symbolize_keys, food_snapshot: saved.food_snapshot }
        else
          MealCatalog.new(@meal.user).find(source: @source, id: @source_id)
        end
        if @unit == "servings"
          portion = food[:portion_grams]
          raise ArgumentError, "Esta receita não possui rendimento válido para registrar porções." unless portion&.positive?

          @quantity = (@quantity * portion).round(4)
          raise ArgumentError, "A quantidade convertida em gramas deve ser positiva e menor que 100 milhões." unless @quantity.positive? && @quantity < 100_000_000
        end
        item = @meal.nutrition_meal_items.find_or_initialize_by(source: @source, source_id: food[:id].to_s)
        existing = item.persisted?
        item.food_snapshot = food[:food_snapshot] if !existing && food[:food_snapshot]
        item.name = food[:name]
        item.quantity_grams = (item.quantity_grams || 0) + @quantity
        NutritionMealItem::NUTRIENTS.each do |field|
          value = food[:nutrients][field]
          added = value.nil? ? nil : value.to_d * @quantity / 100
          stored = item.public_send(field)
          item.public_send("#{field}=", existing ? (stored + added if stored && added) : added)
        end
        item.addition_tokens = item.addition_tokens + [ @token ]
        item.save!
        item
      end
    end
  end
end
