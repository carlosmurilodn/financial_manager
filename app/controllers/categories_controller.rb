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
        # Turbo: fecha o modal e recarrega a página inteira.
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(categories_path)
        end

        # Fallback HTML.
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
    categories = current_user.categories.to_a
    @description_filter = params[:description].to_s.strip

    if @description_filter.present?
      normalized_description = normalize_category_filter(@description_filter)

      categories = categories.select do |category|
        category.normalized_name.include?(normalized_description)
      end
    end

    month_range = Date.current.beginning_of_month..Date.current.end_of_month
    current_expenses = current_user.expenses.where(balance_month: month_range)
    current_incomes = current_user.incomes.where(balance_month: month_range)

    @categories_month_expenses = Expense.effective_sum(current_expenses)
    @categories_month_incomes = current_incomes.sum(:amount)

    @categories_top_expense_value =
      current_expenses.group_by(&:category_id).values.map { |expenses| expenses.sum(&:effective_amount).abs }.max || 0

    @categories_uncategorized_value =
      Expense.effective_sum(current_expenses.where(category_id: nil)) +
      current_incomes.where(category_id: nil).sum(:amount)

    @categories = categories.sort_by(&:sort_name)
  end

  def normalize_category_filter(value)
    value
      .unicode_normalize(:nfkd)
      .encode("ASCII", replace: "", undef: :replace)
      .downcase
      .gsub(/[^a-z0-9]+/, " ")
      .squeeze(" ")
      .strip
  end

  def set_category
    @category = current_user.categories.find(params[:id])
  end
  
  def category_params
    params.require(:category).permit(:name, :icon, :color)
  end
end
