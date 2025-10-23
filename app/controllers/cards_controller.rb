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
        # Turbo: fecha o modal e recarrega a página inteira
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "modal",
            "<turbo-stream action='visit' target='_top' url='#{cards_path}'></turbo-stream>".html_safe
          )
        end

        # Fallback HTML
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

  # -------------------------------
  # Nova action: Pagar todas as despesas e parcelas não pagas do mês atual
  # -------------------------------
  def pay
    start_of_month = Date.current.beginning_of_month
    end_of_month   = Date.current.end_of_month

    credit_methods = [
      Expense.payment_methods[:credito_a_vista],
      Expense.payment_methods[:credito_parcelado]
    ]

    ActiveRecord::Base.transaction do
      # Atualiza despesas não pagas do cartão no mês atual
      updated_expenses_count = @card.expenses
                                    .where(paid: false, payment_method: credit_methods)
                                    .where(balance_month: start_of_month..end_of_month)
                                    .update_all(paid: true)

      # Atualiza parcelas não pagas do cartão no mês atual
      updated_installments_count = Installment.joins(:expense)
                                              .where(paid: false)
                                              .where(expenses: { card_id: @card.id, payment_method: credit_methods })
                                              .where(installments: { balance_month: start_of_month..end_of_month })
                                              .update_all(paid: true)

      flash[:notice] = "Pagamentos atualizados: #{updated_expenses_count} despesas e #{updated_installments_count} parcelas marcadas como pagas."
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

  def remaining_limit
    total_expenses = expenses.where(paid: false).sum(:amount)
    total_installments = installments.where(paid: false).sum(:amount)
    limit - (total_expenses + total_installments)
  end


  # -------------------------------
  # Strong parameters com normalização
  # -------------------------------
  def card_params
    permitted = params.require(:card).permit(
      :name,
      :number,
      :total_limit,
      :due_day,
      :best_day
    )

    permitted[:total_limit] = parse_brazilian_currency(permitted[:total_limit])
    permitted
  end

  def parse_brazilian_currency(value)
    return nil if value.blank?
    value.to_s.gsub(/[^\d,]/, "").gsub(".", "").gsub(",", ".").to_f
  end
end
