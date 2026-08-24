class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    load_categories
  end

  def new
    @category = current_user.categories.new
  end

  def create
    @category = current_user.categories.new(category_params)

    if @category.save
      success_message = "Categoria criada com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(categories_path)
        end

        format.html { redirect_to categories_path, notice: success_message }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      success_message = "Categoria atualizada com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(categories_path)
        end
        format.html { redirect_to categories_path, notice: success_message }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, formats: [ :html ], status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy
    load_categories
    success_message = "Categoria removida com sucesso!"

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = success_message
        render :destroy
      end
      format.html { redirect_to categories_path, notice: success_message }
    end
  end

  private

  def load_categories
    @description_filter = params[:description].to_s.strip

    session[:categories_month] = params[:month].to_i if params[:month].present?
    @month = session[:categories_month]
    @month = nil if @month.blank? || @month == 0
    @month ||= Date.current.month

    session[:categories_year] = params[:year].to_i if params[:year].present?
    @year = session[:categories_year]
    @year = nil if @year.blank? || @year == 0
    @year ||= Date.current.year

    result = Categories::IndexQuery.new(user: current_user, description: @description_filter, month: @month, year: @year).call

    @categories = result.categories
    @categories_month_expenses = result.month_expenses
    @categories_month_incomes = result.month_incomes
    @categories_top_expense_value = result.top_expense_value
    @categories_uncategorized_value = result.uncategorized_value
    @category_expenses_by_id = result.expenses_by_category
    @category_incomes_by_id = result.incomes_by_category
  end

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :icon, :color)
  end
end
