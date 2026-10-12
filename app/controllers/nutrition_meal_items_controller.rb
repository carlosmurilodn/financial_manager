class NutritionMealItemsController < ApplicationController
  include NutritionMealResponses
  helper TacoFoodsHelper
  before_action :set_meal

  def search
    foods = Nutrition::MealCatalog.new(current_user).search(name: params[:name].to_s.strip, source: params[:source].presence || "all")
    render json: { foods: foods }
  end

  def create
    attributes = params.require(:nutrition_meal_item).permit(:source, :source_id, :quantity_grams, :request_token)
    Nutrition::AddMealItem.new(meal: @meal, **attributes.to_h.symbolize_keys).call
    render json: item_summary_payload(@meal).merge(message: "Item salvo na refeição.")
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.join(". ") }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Alimento ou receita indisponível. Pesquisa e quantidade foram preservadas." }, status: :unprocessable_entity
  rescue ArgumentError
    render json: { error: "Informe origem, alimento, quantidade positiva e identificador de inclusão válidos." }, status: :unprocessable_entity
  end

  def update
    quantity = params.require(:nutrition_meal_item).permit(:quantity_grams)[:quantity_grams]
    Nutrition::UpdateMealItem.new(meal: @meal, item_id: params[:id], quantity_grams: quantity).call
    render json: item_summary_payload(@meal).merge(message: "Quantidade e totais atualizados.")
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.join(". ") }, status: :unprocessable_entity
  rescue ArgumentError => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def destroy
    @meal.with_lock { @meal.nutrition_meal_items.find_by(id: params[:id])&.destroy! }
    render json: item_summary_payload(@meal).merge(message: "Item excluído da refeição.")
  end

  private

  def set_meal
    @meal = current_user.nutrition_meals.find(params[:nutrition_meal_id])
  end
end
