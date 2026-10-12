class CustomFoodsController < ApplicationController
  helper TacoFoodsHelper

  before_action :set_custom_food, only: %i[show edit update destroy]

  def new
    @custom_food = current_user.custom_foods.new
  end

  def show
  end

  def edit
  end

  def create
    @custom_food = current_user.custom_foods.new(custom_food_params)
    if @custom_food.save
      redirect_to custom_food_path(@custom_food), notice: "Alimento criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @custom_food.update(custom_food_params)
      redirect_to custom_food_path(@custom_food), notice: "Alimento atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_food.destroy!
    redirect_to taco_foods_path(source: "custom"), notice: "Alimento excluído com sucesso!", status: :see_other
  end

  private

  def set_custom_food
    @custom_food = current_user.custom_foods.find(params[:id])
  end

  def custom_food_params
    params.require(:custom_food).permit(:name, :category, *CustomFood::NUTRIENTS)
  end
end
