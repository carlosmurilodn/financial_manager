module Nutrition
  class AddMealItem
    def initialize(meal:, source:, source_id:, quantity_grams:, request_token:)
      @meal = meal
      @source = source.to_s
      @source_id = source_id.to_s
      @quantity = BigDecimal(quantity_grams.to_s)
      @token = request_token.to_s
    rescue ArgumentError
      raise ArgumentError, "Informe uma quantidade válida em gramas."
    end

    def call
      raise ArgumentError, "Informe uma quantidade positiva com até quatro casas decimais." unless @quantity.finite? && @quantity.positive? && @quantity < 100_000_000 && @quantity == @quantity.round(4)
      raise ArgumentError, "Identificador de inclusão inválido." unless @token.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

      @meal.with_lock do
        previous = @meal.nutrition_meal_items.where("addition_tokens @> ?::jsonb", [ @token ].to_json).first
        next previous if previous

        food = MealCatalog.new(@meal.user).find(source: @source, id: @source_id)
        item = @meal.nutrition_meal_items.find_or_initialize_by(source: @source, source_id: food[:id].to_s)
        existing = item.persisted?
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
