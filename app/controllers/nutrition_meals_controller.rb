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

  def copy
    meal = current_user.nutrition_meals.find(params[:id])
    attributes = params.permit(:request_token, dates: [])
    destinations = Nutrition::CopyMeal.new(user: current_user, meal: meal,
      dates: attributes[:dates], request_token: attributes[:request_token]).call
    days = destinations.map do |destination|
      date = destination.occurred_on
      meals = current_user.nutrition_meals.includes(:nutrition_meal_items).where(occurred_on: date).order(:created_at, :id).to_a
      meals.sort_by! { |item| Nutrition::EnsureWeekMeals::DEFAULT_NAMES.index(item.name) || 5 }
      day_summary_payload(date).merge(date: date.iso8601,
        meals_html: render_to_string(partial: "nutrition_meals/meal", collection: meals, as: :meal, formats: [ :html ]))
    end
    render json: { days: days, message: "Refeição copiada para #{destinations.size} dia(s)." }
  rescue ArgumentError
    render json: { error: "Selecione ao menos um dia válido de destino. A refeição deve conter itens." }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.join(". ") }, status: :unprocessable_entity
  end
end
