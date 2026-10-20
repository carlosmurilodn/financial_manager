module Nutrition
  class CopyMeal
    def initialize(user:, meal:, dates:, request_token:)
      @user = user
      @meal = meal
      @dates = Array(dates).map { |date| Date.iso8601(date.to_s) }.uniq.sort
      token = request_token.to_s
      raise ArgumentError, "Identificador de cópia inválido." unless token.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

      @token = "copy:#{token}"
    end

    def call
      week = @meal.occurred_on.beginning_of_week(:monday)
      unless @dates.any? && @dates.all? { |date| (week..week + 6.days).cover?(date) && date != @meal.occurred_on }
        raise ArgumentError, "Selecione dias desta semana, diferentes do dia de origem."
      end

      destinations = []
      @user.with_lock do
        source = @user.nutrition_meals.lock.find(@meal.id)
        items = source.nutrition_meal_items.order(:id).to_a
        raise ArgumentError, "Adicione itens à refeição antes de copiá-la." if items.empty?

        @dates.each do |date|
          target = @user.nutrition_meals.where(occurred_on: date, name: source.name).order(:id).lock.first
          target ||= @user.nutrition_meals.create!(occurred_on: date, name: source.name)
          destinations << target
          next if target.nutrition_meal_items.where("addition_tokens @> ?::jsonb", [ @token ].to_json).exists?

          items.each do |original|
            item = target.nutrition_meal_items.find_or_initialize_by(source: original.source, source_id: original.source_id)
            existing = item.persisted?
            if existing && original.source == "tabnut" && !item.same_tabnut_composition?(original)
              raise ArgumentError, "O alimento TabNut no destino possui dados diferentes. Mova ou remova esse item antes de copiar."
            end
            item.food_snapshot = original.food_snapshot unless existing
            item.name = original.name
            item.quantity_grams = (item.quantity_grams || 0) + original.quantity_grams
            NutritionMealItem::NUTRIENTS.each do |field|
              value = original.public_send(field)
              stored = item.public_send(field)
              item.public_send("#{field}=", existing ? (stored + value if stored && value) : value)
            end
            item.addition_tokens = item.addition_tokens + [ @token ]
            item.last_added_at = Time.current
            item.save!
          end
        end
      end
      destinations
    end
  end
end
