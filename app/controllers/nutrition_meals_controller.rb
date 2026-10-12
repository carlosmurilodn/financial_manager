class NutritionMealsController < ApplicationController
  helper TacoFoodsHelper

  def create
    week = Date.iso8601(params[:week_start].to_s)
    attributes = params.require(:nutrition_meal).permit(:name, :occurred_on)
    date = Date.iso8601(attributes[:occurred_on].to_s)
    raise ArgumentError unless (week..week + 6.days).cover?(date)

    meal = current_user.nutrition_meals.new(attributes)
    if meal.save
      render json: { html: render_to_string(partial: "nutrition_meals/meal", formats: [ :html ], locals: { meal: meal }), message: "Refeição adicionada." }, status: :created
    else
      render json: { error: meal.errors.full_messages.join(". ") }, status: :unprocessable_entity
    end
  rescue ArgumentError
    render json: { error: "Selecione um dia válido desta semana." }, status: :unprocessable_entity
  end
end
