class CardsController < ApplicationController
  before_action :set_card, only: %i[edit update destroy]

  def index
    @cards = Card.order(:name)
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)
    if @card.save
      redirect_to cards_path, notice: "Cartão criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @card.update(card_params)
      redirect_to cards_path, notice: "Cartão atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cards_path, notice: "Cartão removido com sucesso!" }
    end
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:name, :number)
  end
end
