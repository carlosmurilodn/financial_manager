class CardsController < ApplicationController
  before_action :set_card, only: %i[edit update destroy pay]

  def index
    load_cards
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

    redirect_to cards_path, notice: "Filtros limpos com sucesso!"
  end

  def pay
    balance_month = selected_pay_balance_month
    balance_month_range = balance_month.beginning_of_month..balance_month.end_of_month
    now = Time.current

    ActiveRecord::Base.transaction do
      updated_expenses_count = @card.expenses
                                    .where(user: current_user)
                                    .where(paid: false, payment_method: Expense.card_payment_method_values)
                                    .where(balance_month: balance_month_range)
                                    .update_all(paid: true, paid_at: now, updated_at: now)

      flash[:notice] = "Pagamentos atualizados: #{updated_expenses_count} lançamentos marcados como pagos para #{balance_month.strftime('%m/%Y')}."
    end

    redirect_to cards_path
  rescue => e
    Rails.logger.error("Erro ao pagar cartão ##{@card.id}: #{e.message}\n#{e.backtrace.first(8).join("\n")}")
    flash[:alert] = "Ocorreu um erro ao processar o pagamento: #{e.message}"
    redirect_to cards_path
  end

  private

  def load_cards
    load_card_filters
    @pay_balance_month = selected_pay_balance_month
    @pay_balance_month_label = @pay_balance_month.strftime("%m/%Y")

    debt_scope = card_debt_scope
    expense_scope = card_expense_scope
    @card_debt_years = debt_year_options(debt_scope)
    filtered_debt_scope = apply_card_debt_filters(debt_scope)
    accumulated_debt_scope = apply_card_accumulated_debt_period(debt_scope)
    projected_limit_scope = apply_card_projected_limit_period(debt_scope)
    month_expense_scope = apply_card_month_expense_period(expense_scope, accumulated_debt_scope)
    card_ids_from_debt = card_filter_match_scope(filtered_debt_scope, accumulated_debt_scope)
                         .distinct
                         .pluck(:card_id)
    @card_debt_totals_by_card = Expense.effective_sum_by_card(accumulated_debt_scope)
    @card_projected_limit_totals_by_card = Expense.effective_sum_by_card(projected_limit_scope)
    @card_month_totals_by_card = Expense.effective_sum_by_card(month_expense_scope)

    cards = current_user.cards.order(:name).to_a
    cards = cards.select { |card| card_matches_filters?(card, card_ids_from_debt) } if card_filters_active?

    @cards_limit_total = cards.sum { |card| card.total_limit.to_f }
    @cards_limit_available = cards.sum { |card| remaining_limit_for(card) }
    @cards_limit_used = @cards_limit_total - @cards_limit_available
    @cards_open_invoices = cards.sum { |card| @card_debt_totals_by_card.fetch(card.id, 0).to_f }

    cards = sort_collection(cards, sort_map: card_sort_map, default_sort: "name")

    @per_page = pagination_per_page(:cards_per_page)
    @cards = paginate_collection(cards, per_page: @per_page)

    @item_offset = ((@current_page.to_i - 1) * @per_page.to_i)
  end

  def load_card_filters
    session[:cards_description] = params[:description].to_s.strip if params.key?(:description)
    @description_filter = session[:cards_description].presence

    session[:cards_month] = params[:month].to_i if params[:month].present?
    @month = session[:cards_month]
    @month = nil if @month.blank? || @month.zero?

    session[:cards_year] = params[:year].to_i if params[:year].present?
    @year = session[:cards_year]
    @year = nil if @year.blank? || @year.zero?
  end

  def card_debt_scope
    current_user.expenses
                .where(paid: false, payment_method: Expense.card_payment_method_values)
                .where.not(card_id: nil)
  end

  def card_expense_scope
    current_user.expenses
                .where(payment_method: Expense.card_payment_method_values)
                .where.not(card_id: nil)
  end

  def apply_card_debt_filters(scope)
    filtered_scope = scope
    filtered_scope = filtered_scope.where("EXTRACT(MONTH FROM balance_month) = ?", @month) if @month.present?
    filtered_scope = filtered_scope.where("EXTRACT(YEAR FROM balance_month) = ?", @year) if @year.present?

    apply_card_description_filter(filtered_scope)
  end

  def apply_card_accumulated_debt_period(scope)
    return apply_card_description_filter(scope) unless complete_period_filter?

    apply_card_description_filter(scope.where("balance_month >= ?", Date.new(@year, @month, 1)))
  rescue ArgumentError
    apply_card_description_filter(scope)
  end

  def apply_card_projected_limit_period(scope)
    return apply_card_description_filter(scope) unless complete_period_filter?

    apply_card_description_filter(scope.where("balance_month >= ?", Date.new(@year, @month, 1).next_month))
  rescue ArgumentError
    apply_card_description_filter(scope)
  end

  def apply_card_month_expense_period(scope, fallback_scope)
    return fallback_scope unless complete_period_filter?

    balance_month = Date.new(@year, @month, 1)
    apply_card_description_filter(scope.where(balance_month: balance_month.all_month))
  rescue ArgumentError
    fallback_scope
  end

  def apply_card_description_filter(scope)
    return scope if @description_filter.blank?

    query = "%#{@description_filter.downcase}%"
    matching_card_ids = current_user.cards.where("LOWER(name) LIKE ?", query).pluck(:id)

    return scope.where("LOWER(description) LIKE ?", query) if matching_card_ids.blank?

    scope.where("LOWER(description) LIKE :query OR card_id IN (:card_ids)", query: query, card_ids: matching_card_ids)
  end

  def debt_year_options(scope)
    scope.pluck(:balance_month)
         .compact
         .map(&:year)
         .uniq
         .sort
  end

  def card_filters_active?
    @description_filter.present? || @month.present? || @year.present?
  end

  def complete_period_filter?
    @month.present? && @year.present?
  end

  def card_filter_match_scope(filtered_debt_scope, accumulated_debt_scope)
    complete_period_filter? ? accumulated_debt_scope : filtered_debt_scope
  end

  def card_matches_filters?(card, card_ids_from_debt)
    card_ids_from_debt.include?(card.id)
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
