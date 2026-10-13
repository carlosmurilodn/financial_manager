class NutritionMealItemsController < ApplicationController
  include NutritionMealResponses
  helper TacoFoodsHelper
  before_action :set_meal

  def show
    @item = @meal.nutrition_meal_items.find(params[:id])
    @nutrients = Nutrition::MealItemDetails.new(@item).nutrients
  end

  def search
    foods = Nutrition::MealCatalog.new(current_user).search(name: params[:name].to_s.strip, source: params[:source].presence || "all")
    render json: { foods: foods }
  end

  def create
    attributes = params.require(:nutrition_meal_item).permit(:source, :source_id, :quantity_grams, :quantity, :unit, :request_token)
    Nutrition::AddMealItem.new(meal: @meal, **attributes.to_h.symbolize_keys).call
    render json: item_summary_payload(@meal).merge(message: "Item salvo na refeição.")
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.join(". ") }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Alimento ou receita indisponível. Pesquisa e quantidade foram preservadas." }, status: :unprocessable_entity
  rescue ArgumentError => error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def update
    quantity = params.require(:nutrition_meal_item).permit(:quantity_grams)[:quantity_grams]
    Nutrition::UpdateMealItem.new(meal: @meal, item_id: params[:id], quantity_grams: quantity).call
    respond_to do |format|
      format.json { render json: item_summary_payload(@meal).merge(message: "Quantidade e totais atualizados.") }
      format.html { redirect_to nutrition_meal_nutrition_meal_item_path(@meal, params[:id]), notice: "Quantidade e totais atualizados.", status: :see_other }
    end
  rescue ActiveRecord::RecordInvalid => error
    render_update_error(error.record.errors.full_messages.join(". "))
  rescue ArgumentError => error
    render_update_error(error.message)
  end

  def destroy
    @meal.with_lock { @meal.nutrition_meal_items.find_by(id: params[:id])&.destroy! }
    respond_to do |format|
      format.json { render json: item_summary_payload(@meal).merge(message: "Item excluído da refeição.") }
      format.html { redirect_to meal_week_path, notice: "Item excluído da refeição.", status: :see_other }
    end
  end

  private

  def render_update_error(message)
    respond_to do |format|
      format.json { render json: { error: message }, status: :unprocessable_entity }
      format.html do
        show
        @quantity = params.dig(:nutrition_meal_item, :quantity_grams)
        flash.now[:alert] = message
        render :show, status: :unprocessable_entity
      end
    end
  end

  def meal_week_path
    health_nutrition_week_path(@meal.occurred_on.beginning_of_week(:monday).iso8601, day: @meal.occurred_on.iso8601)
  end
  helper_method :meal_week_path

  def set_meal
    @meal = current_user.nutrition_meals.find(params[:nutrition_meal_id])
  end
end
