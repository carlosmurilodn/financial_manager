class NutritionMealsController < ApplicationController
  include NutritionMealResponses
  helper TacoFoodsHelper

  def create
    week = Date.iso8601(params[:week_start].to_s)
    attributes = params.require(:nutrition_meal).permit(:name, :occurred_on)
    date = Date.iso8601(attributes[:occurred_on].to_s)
    raise ArgumentError unless (week..week + 6.days).cover?(date)

    meal = current_user.nutrition_meals.new(attributes)
    if meal.save
      render json: day_summary_payload(date).merge(html: render_to_string(partial: "nutrition_meals/meal", formats: [ :html ], locals: { meal: meal }), message: "Refeição adicionada."), status: :created
    else
      render json: { error: meal.errors.full_messages.join(". ") }, status: :unprocessable_entity
    end
  rescue ArgumentError
    render json: { error: "Selecione um dia válido desta semana." }, status: :unprocessable_entity
  end

  def destroy
    meal = current_user.nutrition_meals.find(params[:id])
    date = meal.occurred_on
    meal.with_lock { meal.destroy! }
    render json: day_summary_payload(date).merge(message: "Refeição e seus itens excluídos.")
  end
end
