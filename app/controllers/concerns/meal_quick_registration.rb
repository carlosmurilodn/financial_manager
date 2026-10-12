module MealQuickRegistration
  extend ActiveSupport::Concern

  included do
    before_action :load_registration_meal, only: %i[new create]
  end

  private

  def load_registration_meal
    return if params[:nutrition_meal_id].blank?

    @registration_meal = current_user.nutrition_meals.find(params[:nutrition_meal_id])
  end

  def render_meal_registration(resource:, partial:, locals:, title:, status: :ok)
    render partial: "nutrition_meals/quick_registration", formats: [ :html ], status: status,
      locals: { resource: resource, form_partial: partial, form_locals: locals,
                meal: @registration_meal, title: title }
  end

  def render_registered_food(record, source)
    food = Nutrition::MealCatalog.new(current_user).find(source: source, id: record.id)
    render json: { food: food, nutrition_meal_id: @registration_meal.id,
                   message: "Cadastro salvo. Informe a quantidade e clique em + para adicionar à refeição." }, status: :created
  end
end
