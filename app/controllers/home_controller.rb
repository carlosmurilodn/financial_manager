class HomeController < ApplicationController
  # Constantes para facilitar a manutenção e legibilidade
  RECENT_EXPENSES_LIMIT = 6
  RECENT_INCOMES_LIMIT = 6
  MONTHS_FOR_CHART = 4

  def index
    set_current_dates
    calculate_kpis
    set_card_balances
    set_category_expenses_data
    set_monthly_chart_data
    set_calendar_data
    set_recent_expenses
    prepare_calendar_data
    set_forecast_data # <-- substitui o antigo forecast
    @recent_incomes = Income.order(date: :desc).limit(RECENT_INCOMES_LIMIT)
  end

  private

  # --- Datas e Períodos ---
  def set_current_dates
    @hoje = Date.current
    # Período do mês atual
    @mes_atual = @hoje.all_month
    # Mês e ano selecionado (ou atual) para o calendário e forecast
    @month = (params[:month] || @hoje.month).to_i
    @year = (params[:year] || @hoje.year).to_i
    start_date = Date.new(@year, @month, 1)
    @calendar_range = start_date.all_month
  end

  # --- Consultas Reutilizáveis ---
  def data_in_month(model, month_range)
    model.where(balance_month: month_range)
  end

  def total_balance_before(model, date)
    model.where('balance_month <= ?', date.end_of_month).sum(:amount)
  end

  def total_expenses_and_installments(month_range, category_id = nil, card_id = nil)
    expenses_query = Expense.where(balance_month: month_range)
    expenses_query = expenses_query.where(category_id: category_id) if category_id.present?
    expenses_query = expenses_query.where(card_id: card_id) if card_id.present?

    installments_query = Installment.where(balance_month: month_range)
    if category_id.present?
      installments_query = installments_query.joins(:expense).where(expenses: { category_id: category_id })
    end
    if card_id.present?
      installments_query = installments_query.joins(:expense).where(expenses: { card_id: card_id })
    end

    expenses_query.sum(:amount) + installments_query.sum(:amount)
  end

  # --- KPIs ---
  def calculate_kpis
    @saldo_atual = total_balance_before(Income, @hoje) -
                   total_balance_before(Expense, @hoje) -
                   total_balance_before(Installment, @hoje)

    @receitas_mes = data_in_month(Income, @mes_atual).sum(:amount)
    @despesas_mes = total_expenses_and_installments(@mes_atual)
    @saldo_liquido = Income.sum(:amount) - Expense.sum(:amount) - Installment.sum(:amount)
  end

  # --- Saldo por cartão ---
  def set_card_balances
    @cards_info = Card.all.map do |card|
      { card: card, total: total_expenses_and_installments(@mes_atual, nil, card.id) }
    end
  end

  # --- Despesas por categoria ---
  def set_category_expenses_data
    @despesas_por_categoria = Category.all.map do |cat|
      total = total_expenses_and_installments(@mes_atual, cat.id)
      [cat.name, total]
    end.reject { |_, total| total.zero? }
       .sort_by { |_, total| -total }
       .to_h

    set_category_details
  end

  def set_category_details
    expense_ids_with_installments = Installment.where(balance_month: @mes_atual).pluck(:expense_id).uniq

    @detalhes_despesas_por_categoria =
      Expense.includes(:installments, :category)
             .where(balance_month: @mes_atual)
             .or(Expense.where(id: expense_ids_with_installments))
             .group_by { |e| e.category.name }
             .transform_values { |expenses| format_expense_details(expenses) }
  end

  def format_expense_details(expenses)
    expenses.flat_map do |e|
      parcelas_no_mes = e.installments.where(balance_month: @mes_atual)
      h = ActionController::Base.helpers

      if e.payment_method_credito_parcelado? && parcelas_no_mes.any?
        parcelas_no_mes.map do |p|
          valor_parcela = h.number_to_currency(p.amount, unit: 'R$ ', separator: ',', delimiter: '.')
          "#{e.description} - Parcela #{p.number}/#{e.installments_count} (#{valor_parcela})"
        end
      elsif @mes_atual.cover?(e.balance_month) && !e.payment_method_credito_parcelado?
        valor = h.number_to_currency(e.amount, unit: 'R$ ', separator: ',', delimiter: '.')
        ["#{e.description} (#{valor})"]
      else
        []
      end
    end
  end

  # --- Receitas x Despesas (últimos X meses) ---
  def set_monthly_chart_data
    @meses_datas = MONTHS_FOR_CHART.times.map { |i| @hoje - i.months }.reverse
    @meses_labels = @meses_datas.map { |d| d.strftime('%B') }

    @receitas_mensais = @meses_datas.map { |data| data_in_month(Income, data.all_month).sum(:amount) }
    @despesas_mensais = @meses_datas.map { |data| total_expenses_and_installments(data.all_month) }
  end

  # --- Dados do Calendário (Não Pagos) ---
  def set_calendar_data
    @calendar_expenses_not_paid = Expense.where(paid: false, date: @calendar_range).includes(:category)
    @calendar_installments_not_paid = Installment.where(paid: false, due_date: @calendar_range).includes(expense: :category)
  end

  # --- Despesas Recentes ---
  def set_recent_expenses
    current_month_range = Date.current.all_month

    normal_expenses = Expense.where.not(payment_method: :credito_parcelado)
                              .where(balance_month: current_month_range)
                              .includes(:category)
                              .select(:id, :description, :amount, :date, :category_id)

    installment_expenses = Installment.joins(:expense)
                                      .includes(expense: :category)
                                      .where(balance_month: current_month_range)
                                      .select("installments.id AS id, expenses.id AS expense_id, expenses.description AS description, installments.amount AS amount, installments.due_date AS date, expenses.category_id AS category_id")

    @recent_expenses = (normal_expenses.to_a + installment_expenses.to_a)
                       .sort_by(&:date)
                       .last(RECENT_EXPENSES_LIMIT)
  end

  # --- Pré-processamento do calendário ---
  def prepare_calendar_data
    start_date = @calendar_range.begin.beginning_of_week(:sunday)
    end_date = @calendar_range.end.end_of_week(:sunday)
    @calendar_weeks = (start_date..end_date).to_a.in_groups_of(7)

    @daily_expenses = {}
    combined_items = @calendar_expenses_not_paid.to_a + @calendar_installments_not_paid.to_a

    combined_items.each do |item|
      date = item.respond_to?(:date) ? item.date : item.due_date
      @daily_expenses[date] ||= []
      expense_data = {
        amount: item.amount,
        description: item.try(:description) || item.try(:expense)&.description,
        category_emoji: (item.try(:category) || item.try(:expense)&.category)&.emoji
      }
      @daily_expenses[date] << expense_data
    end
  end

  # --- Previsão Financeira ---
  def set_forecast_data
    @months = (1..12).to_a
    @forecast_data = {}

    # Saldo acumulado até o mês anterior ao ano atual
    total_receitas_anteriores = Income.where("balance_month < ?", Date.new(@year, 1, 1)).sum(:amount)
    total_despesas_anteriores = Expense.where("balance_month < ?", Date.new(@year, 1, 1)).sum(:amount) +
                                Installment.where("balance_month < ?", Date.new(@year, 1, 1)).sum(:amount)

    @months.each do |month|
      month_range = Date.new(@year, month, 1).all_month

      # Receitas do mês atual
      receitas_mes = Income.where(balance_month: month_range).sum(:amount)

      # Despesas do mês atual
      despesas_mes = Expense.where(balance_month: month_range).sum(:amount) +
                      Installment.where(balance_month: month_range).sum(:amount)

      # Total de Receitas = saldo acumulado até mês anterior + receitas do mês atual
      saldo_anteriores = total_receitas_anteriores - total_despesas_anteriores
      total_receitas = saldo_anteriores + receitas_mes

      # Saldo líquido do mês = total de receitas - despesas do mês atual
      saldo_liquido = total_receitas - despesas_mes

      @forecast_data[month] = {
        receitas: total_receitas,
        despesas: despesas_mes,
        saldo: saldo_liquido
      }

      # Atualiza acumulados para o próximo mês
      total_receitas_anteriores += receitas_mes
      total_despesas_anteriores += despesas_mes
    end
  end
end
