class CardsController < ApplicationController
  before_action :set_card, only: %i[edit update destroy pay]

  def index
    load_cards
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
    load_cards

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

  def load_cards
    cards = Card.order(:name).to_a
    @cards_limit_total = cards.sum { |card| card.total_limit.to_f }
    @cards_limit_available = cards.sum { |card| card.remaining_limit.to_f }
    @cards_limit_used = @cards_limit_total - @cards_limit_available

    credit_methods = [
      Expense.payment_methods[:credito_a_vista],
      Expense.payment_methods[:credito_parcelado]
    ]

    @cards_open_invoices = Expense.where(paid: false, payment_method: credit_methods).sum(:amount)
    cards = sort_collection(cards, sort_map: card_sort_map, default_sort: "name")
    @cards = paginate_collection(cards, per_page: pagination_per_page(:cards_per_page))
  end

  def card_sort_map
    {
      "name" => ->(card) { card.name.to_s },
      "number" => ->(card) { card.number.to_s },
      "total_limit" => ->(card) { card.total_limit.to_d },
      "remaining_limit" => ->(card) { card.remaining_limit.to_d },
      "due_day" => ->(card) { card.due_day.to_i },
      "closing_day" => ->(card) { card.closing_day.to_i }
    }
  end

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
      :closing_day
    )
  end

  def remove_icon_attachment_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(params.dig(:card, :remove_icon))
    return if params.dig(:card, :icon).present?

    @card.icon.purge_later if @card.icon.attached?
  end
end
