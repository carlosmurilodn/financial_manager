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
      respond_to do |format|
        # Turbo: fecha o modal e recarrega a página inteira
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "modal",
            "<turbo-stream action='visit' target='_top' url='#{categories_path}'></turbo-stream>".html_safe
          )
        end

        # Fallback HTML
        format.html { redirect_to categories_path, notice: "Categoria criada com sucesso!" }
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
      redirect_to categories_path, notice: "Categoria atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    load_categories

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to categories_path, notice: "Categoria removida com sucesso!" }
    end
  end

  private

  def load_categories
    categories = current_user.categories.order(:name).to_a
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

    @categories_month_expenses = current_expenses.sum(:amount)
    @categories_month_incomes = current_incomes.sum(:amount)
    @categories_top_expense_value = current_expenses.group(:category_id).sum(:amount).values.max || 0
    @categories_uncategorized_value = current_expenses.where(category_id: nil).sum(:amount) +
                                      current_incomes.where(category_id: nil).sum(:amount)
    categories = sort_collection(categories, sort_map: category_sort_map, default_sort: "name")
    @categories = paginate_collection(categories, per_page: pagination_per_page(:categories_per_page))
  end

  def category_sort_map
    {
      "icon" => ->(category) { category.material_icon.to_s },
      "name" => ->(category) { category.display_name.to_s }
    }
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
    params.require(:category).permit(:name, :icon)
  end
end