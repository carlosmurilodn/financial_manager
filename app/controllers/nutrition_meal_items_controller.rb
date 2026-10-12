class NutritionMealItemsController < ApplicationController
  helper TacoFoodsHelper
  before_action :set_meal

  def search
    foods = Nutrition::MealCatalog.new(current_user).search(name: params[:name].to_s.strip, source: params[:source].presence || "all")
    render json: { foods: foods }
  end

  def create
    attributes = params.require(:nutrition_meal_item).permit(:source, :source_id, :quantity_grams, :request_token)
    Nutrition::AddMealItem.new(meal: @meal, **attributes.to_h.symbolize_keys).call
    @meal.nutrition_meal_items.reload
    render json: { html: render_to_string(partial: "nutrition_meals/items", formats: [ :html ], locals: { meal: @meal }), message: "Item salvo na refeição." }
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.join(". ") }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Alimento ou receita indisponível. Pesquisa e quantidade foram preservadas." }, status: :unprocessable_entity
  rescue ArgumentError
    render json: { error: "Informe origem, alimento, quantidade positiva e identificador de inclusão válidos." }, status: :unprocessable_entity
  end

  private

  def set_meal
    @meal = current_user.nutrition_meals.find(params[:nutrition_meal_id])
  end
end
