class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.order(:name)
  end

  def new
    @category = Category.new
  end

def create
  @category = Category.new(category_params)

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
    params.require(:category).permit(:name, :icon)
  end
end
