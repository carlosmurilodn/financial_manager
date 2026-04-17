class CardsController < ApplicationController
  before_action :set_card, only: %i[edit update destroy pay]

  def index
    @cards = Card.order(:name)
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)

    if @card.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "modal",
            "<turbo-stream action='visit' target='_top' url='#{cards_path}'></turbo-stream>".html_safe
          )
        end

        format.html { redirect_to cards_path, notice: "Cartão criado com sucesso!" }
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
    if @card.update(card_params)
      remove_icon_attachment_if_requested
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

  def pay
    start_of_month = Date.current.beginning_of_month
    end_of_month = Date.current.end_of_month

    credit_methods = [
      Expense.payment_methods[:credito_a_vista],
      Expense.payment_methods[:credito_parcelado]
    ]

    ActiveRecord::Base.transaction do
      updated_expenses_count = @card.expenses
                                    .where(paid: false, payment_method: credit_methods)
                                    .where(balance_month: start_of_month..end_of_month)
                                    .update_all(paid: true)

      flash[:notice] = "Pagamentos atualizados: #{updated_expenses_count} despesas marcadas como pagas."
    end

    redirect_to cards_path
  rescue => e
    Rails.logger.error("Erro ao pagar cartão ##{@card.id}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
    flash[:alert] = "Ocorreu um erro ao processar o pagamento: #{e.message}"
    redirect_to cards_path
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(
      :name,
      :number,
      :total_limit,
      :icon,
      :due_day,
      :best_day
    )
  end

  def remove_icon_attachment_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(params.dig(:card, :remove_icon))
    return if params.dig(:card, :icon).present?

    @card.icon.purge_later if @card.icon.attached?
  end
end
