class NutritionRecipesController < ApplicationController
  include MealQuickRegistration
  helper TacoFoodsHelper
  before_action :set_recipe, only: %i[show edit update destroy]
  before_action :load_recipe_source_meal, only: %i[new create]

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
    @recipe = @source_meal ? Nutrition::MealRecipeDraft.new(@source_meal).call : current_user.nutrition_recipes.new(servings: 1)
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
    catalogs = { "taco" => TacoFood.all, "custom" => current_user.custom_foods }
    source = params[:source].presence || "all"
    catalogs.select! { |origin, _| origin == source } unless source == "all"
    foods = catalogs.flat_map do |origin, catalog|
      catalog.search_by_name(params[:name].to_s.strip).order(:name, :id).limit(20).map do |food|
        food.as_json(only: %i[id name calories carbohydrates proteins fats]).merge("source" => origin)
      end
    end
    render json: foods.sort_by { |food| [ I18n.transliterate(food["name"]).downcase, food["source"], food["id"] ] }.first(20)
  end

  private

  def load_recipe_source_meal
    return if params[:from_meal_id].blank?

    @source_meal = current_user.nutrition_meals.includes(:nutrition_meal_items).find(params[:from_meal_id])
    Nutrition::MealRecipeDraft.new(@source_meal).call
  rescue ArgumentError => error
    redirect_to health_nutrition_week_path(@source_meal.occurred_on.beginning_of_week(:monday).iso8601), alert: error.message
  end

  def render_quick_recipe(status: :ok)
    render_meal_registration(resource: @recipe, partial: "nutrition_recipes/form",
      locals: { recipe: @recipe }, title: "Nova Receita", status: status)
  end

  def set_recipe
    @recipe = current_user.nutrition_recipes.includes(:nutrition_recipe_ingredients).find(params[:id])
  end

  def recipe_params
    attributes = params.require(:nutrition_recipe)
    ingredients = attributes[:nutrition_recipe_ingredients_attributes]
    if ingredients.is_a?(ActionController::Parameters)
      attributes = attributes.deep_dup
      attributes[:nutrition_recipe_ingredients_attributes] = ingredients.values
    end

    permitted = attributes.permit(
      :name, :description, :final_weight_grams, :servings,
      nutrition_recipe_ingredients_attributes: %i[id source source_id quantity_grams _destroy]
    )
    permitted[:servings] = 1 if @source_meal && permitted[:servings].blank?
    permitted
  end
end
