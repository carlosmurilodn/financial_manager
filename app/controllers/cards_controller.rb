class CardsController < ApplicationController
  before_action :set_card, only: %i[show edit update destroy pay]

  def index
    load_cards
  end

  def show
    @show_month = params[:month].present? ? params[:month].to_i : Date.current.month
    @show_year = params[:year].present? ? params[:year].to_i : Date.current.year
    @show_date = Date.new(@show_year, @show_month, 1)
    @previous_date = @show_date.prev_month
    @next_date = @show_date.next_month

    @card_expenses = @card.expenses
                          .where(balance_month: @show_date.beginning_of_month..@show_date.end_of_month)
                          .includes(:category)

    # Sorting
    @sort = params[:sort].presence || "created_at"
    @direction = params[:direction].presence || "desc"
    @card_expenses = sort_card_expenses(@card_expenses)

    @card_total_month = Expense.effective_sum(@card_expenses)
    @card_paid_month = Expense.effective_sum(@card_expenses.where(paid: true))
    @card_pending_month = Expense.effective_sum(@card_expenses.where(paid: false))

    # KPIs simulam o mês selecionado como pago:
    # Utilizado = despesas não pagas de OUTROS meses (exclui o mês visualizado)
    @card_used = Expense.effective_sum(
      @card.expenses.where(paid: false).where.not(balance_month: @show_date.beginning_of_month..@show_date.end_of_month)
    )
    @card_remaining = @card.total_limit.to_f - @card_used.to_f
  end

  def new
    @card = current_user.cards.new
  end

  def create
    @card = current_user.cards.new(card_params)

    if @card.save
      success_message = "Cartão criado com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(cards_path)
        end

        format.html { redirect_to cards_path, notice: success_message }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, formats: [:html], status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @card.update(card_params)
      remove_icon_attachment_if_requested
      success_message = "Cartão atualizado com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(cards_path)
        end
        format.html { redirect_to cards_path, notice: success_message }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, formats: [ :html ], status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @card.destroy
    load_cards
    success_message = "Cartão removido com sucesso!"

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = success_message
        render :destroy
      end
      format.html { redirect_to cards_path, notice: success_message }
    end
  end

  def clear_filters
    session.delete(:cards_description)
    session.delete(:cards_month)
    session.delete(:cards_year)
    session.delete(:cards_has_debt)

    redirect_to cards_path, notice: "Filtros limpos com sucesso!"
  end

  def pay
    balance_month = selected_pay_balance_month
    updated_expenses_count = Cards::PayInvoice.call(card: @card, user: current_user, balance_month: balance_month)

    flash[:notice] = "Pagamentos atualizados: #{updated_expenses_count} lançamentos marcados como pagos para #{balance_month.strftime('%m/%Y')}."
    redirect_to card_path(@card, month: balance_month.month, year: balance_month.year)
  rescue => e
    Rails.logger.error("Erro ao pagar cartão ##{@card.id}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
    flash[:alert] = "Ocorreu um erro ao processar o pagamento: #{e.message}"
    balance_month ||= selected_pay_balance_month
    redirect_to card_path(@card, month: balance_month.month, year: balance_month.year)
  end

  private

  def load_cards
    load_card_filters
    @pay_balance_month = selected_pay_balance_month
    @pay_balance_month_label = @pay_balance_month.strftime("%m/%Y")

    result = Cards::IndexQuery.new(
      user: current_user,
      description: @description_filter,
      month: @month,
      year: @year,
      has_debt: @has_debt_filter
    ).call

    assign_card_result(result)

    cards = sort_collection(result.cards, sort_map: card_sort_map, default_sort: "name")

    @per_page = pagination_per_page(:cards_per_page)
    @cards = paginate_collection(cards, per_page: @per_page)

    @item_offset = ((@current_page.to_i - 1) * @per_page.to_i)
  end

  def assign_card_result(result)
    @card_debt_years = result.debt_years
    @card_debt_totals_by_card = result.debt_totals_by_card
    @card_projected_limit_totals_by_card = result.projected_limit_totals_by_card
    @card_month_totals_by_card = result.month_totals_by_card
    @cards_limit_total = result.limit_total
    @cards_limit_available = result.limit_available
    @cards_limit_used = result.limit_used
    @cards_open_invoices = result.open_invoices
  end

  def load_card_filters
    session[:cards_description] = params[:description].to_s.strip if params.key?(:description)
    @description_filter = session[:cards_description].presence

    session[:cards_month] = params[:month].to_i if params[:month].present?
    @month = session[:cards_month]
    @month = nil if @month.blank? || @month.zero?
    @month ||= Date.current.month

    session[:cards_year] = params[:year].to_i if params[:year].present?
    @year = session[:cards_year]
    @year = nil if @year.blank? || @year.zero?
    @year ||= Date.current.year

    session[:cards_has_debt] = params[:has_debt] if params.key?(:has_debt)
    @has_debt_filter = session[:cards_has_debt]
    @has_debt_filter = nil if @has_debt_filter.blank?
  end

  def remaining_limit_for(card)
    card.total_limit.to_f - @card_projected_limit_totals_by_card.fetch(card.id, 0).to_f
  end

  def selected_pay_balance_month
    month = (params[:month].presence || session[:cards_month]).to_i
    year = (params[:year].presence || session[:cards_year]).to_i

    return Date.current.beginning_of_month if month.zero? || year.zero?

    Date.new(year, month, 1)
  rescue ArgumentError
    Date.current.beginning_of_month
  end

  def sort_card_expenses(expenses)
    dir = @direction == "asc" ? :asc : :desc

    case @sort
    when "description"
      expenses.order(description: dir)
    when "category"
      expenses.joins(:category).order("categories.name #{dir}")
    when "amount"
      expenses.order(amount: dir)
    else
      expenses.order(created_at: :desc)
    end
  end

  def card_sort_map
    {
      "name" => ->(card) { card.name.to_s },
      "number" => ->(card) { card.number.to_s },
      "total_limit" => ->(card) { card.total_limit.to_d },
      "remaining_limit" => ->(card) { remaining_limit_for(card).to_d },
      "balance_month_amount" => ->(card) { @card_debt_totals_by_card.fetch(card.id, 0).to_d },
      "due_day" => ->(card) { card.due_day.to_i },
      "closing_day" => ->(card) { card.closing_day.to_i }
    }
  end

  def set_card
    @card = current_user.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(
      :name,
      :number,
      :total_limit,
      :color,
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
