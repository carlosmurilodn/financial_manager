class NutritionRecipesController < ApplicationController
  include MealQuickRegistration
  helper TacoFoodsHelper
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    @name_filter = params[:name].to_s.strip
    @sort = %w[name final_weight_grams servings].include?(params[:sort]) ? params[:sort] : "name"
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    recipes = current_user.nutrition_recipes.search_by_name(@name_filter)
    @filtered_count = recipes.count
    @total_recipe_count = current_user.nutrition_recipes.count
    @filtered_servings = recipes.sum(:servings)
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @recipes = recipes.order(@sort => @direction, id: :asc).limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
    @calculator = Nutrition::RecipeCalculator.new(@recipe)
  end

  def new
    @recipe = current_user.nutrition_recipes.new(servings: 1)
    render_quick_recipe if @registration_meal
  end

  def edit
  end

  def create
    @recipe = current_user.nutrition_recipes.new(recipe_params)
    if Nutrition::SaveRecipe.new(@recipe).call
      if @registration_meal
        render_registered_food(@recipe, "recipe")
      else
        redirect_to nutrition_recipe_path(@recipe), notice: "Receita criada com sucesso!", status: :see_other
      end
    else
      if @registration_meal
        render_quick_recipe(status: :unprocessable_entity)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    @recipe.assign_attributes(recipe_params)
    if Nutrition::SaveRecipe.new(@recipe).call
      redirect_to nutrition_recipe_path(@recipe), notice: "Receita atualizada com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy!
    redirect_to nutrition_recipes_path, notice: "Receita excluída com sucesso!", status: :see_other
  end

  def foods
    catalog = params[:source] == "custom" ? current_user.custom_foods : TacoFood.all
    foods = catalog.search_by_name(params[:name].to_s.strip).order(:name, :id).limit(20)
    render json: foods.map { |food| food.as_json(only: %i[id name calories carbohydrates proteins fats]) }
  end

  private

  def render_quick_recipe(status: :ok)
    render_meal_registration(resource: @recipe, partial: "nutrition_recipes/form",
      locals: { recipe: @recipe }, title: "Nova Receita", status: status)
  end

  def set_recipe
    @recipe = current_user.nutrition_recipes.includes(:nutrition_recipe_ingredients).find(params[:id])
  end

  def recipe_params
    params.require(:nutrition_recipe).permit(
      :name, :description, :final_weight_grams, :servings,
      nutrition_recipe_ingredients_attributes: %i[id source source_id quantity_grams _destroy]
    )
  end
end
