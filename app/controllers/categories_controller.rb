class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    # Ordena pelo nome puro, ignorando emoji
    @categories = Category.order(:name)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "Categoria criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
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

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to categories_path, notice: "Categoria removida com sucesso!" }
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    # Permite emoji + nome juntos
    params.require(:category).permit(:name, :emoji)
  end
end
