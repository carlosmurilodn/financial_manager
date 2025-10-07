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

  # -------------------------------
  # Strong parameters com normalização
  # -------------------------------
  def card_params
    permitted = params.require(:card).permit(
      :name,
      :number,
      :total_limit,
      :remaining_limit,
      :due_day,
      :best_day
    )

    # Normaliza os valores de moeda (ex: "R$ 10.000,00" → 10000.0)
    permitted[:total_limit]     = parse_brazilian_currency(permitted[:total_limit])
    permitted[:remaining_limit] = parse_brazilian_currency(permitted[:remaining_limit])

    permitted
  end

  # Converte string de moeda brasileira para decimal
  def parse_brazilian_currency(value)
    return nil if value.blank?

    value.to_s
         .gsub(/[^\d,]/, "") # remove tudo que não for número ou vírgula
         .gsub(".", "")      # remove pontos de milhar
         .gsub(",", ".")     # troca vírgula por ponto decimal
         .to_f
  end
end
