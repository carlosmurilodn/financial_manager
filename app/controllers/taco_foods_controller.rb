class TacoFoodsController < ApplicationController
  SORT_COLUMNS = %w[name category calories carbohydrates proteins fats].freeze

  def index
    @name_filter = params[:name].to_s.strip
    @category_filter = params[:category].to_s
    @categories = TacoFood.distinct.order(:category).pluck(:category)
    @sort = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    @direction = params[:direction] == "desc" ? "desc" : "asc"

    foods = TacoFood.search_by_name(@name_filter).by_category(@category_filter)
    @filtered_count = foods.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    column = @sort == "name" ? "search_name" : @sort
    @taco_foods = foods.order(column => @direction, id: :asc)
                      .limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
    @taco_food = TacoFood.find(params[:id])
  end
end
