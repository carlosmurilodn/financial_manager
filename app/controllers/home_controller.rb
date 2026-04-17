class HomeController < ApplicationController
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
    set_forecast_data
    @recent_incomes = Income.order(date: :desc).limit(RECENT_INCOMES_LIMIT)
  end

  private

  def set_current_dates
    @hoje = Date.current
    @mes_atual = @hoje.all_month
    @month = (params[:month] || @hoje.month).to_i
    @year = (params[:year] || @hoje.year).to_i
    start_date = Date.new(@year, @month, 1)
    @calendar_range = start_date.all_month
  end

  def data_in_month(model, month_range)
    model.where(balance_month: month_range)
  end

  def total_balance_before(model, date)
    model.where("balance_month <= ?", date.end_of_month).sum(:amount)
  end

  def total_expenses(month_range, category_id = nil, card_id = nil)
    expenses = Expense.where(balance_month: month_range)
    expenses = expenses.where(category_id: category_id) if category_id.present?
    expenses = expenses.where(card_id: card_id) if card_id.present?
    expenses.sum(:amount)
  end

  def calculate_kpis
    @saldo_atual = total_balance_before(Income, @hoje) - total_balance_before(Expense, @hoje)
    @receitas_mes = data_in_month(Income, @mes_atual).sum(:amount)
    @despesas_mes = total_expenses(@mes_atual)
    @saldo_liquido = Income.sum(:amount) - Expense.sum(:amount)
  end

  def set_card_balances
    @cards_info = Card.all.map do |card|
      { card: card, total: total_expenses(@mes_atual, nil, card.id) }
    end
  end

  def set_category_expenses_data
    @despesas_por_categoria = Category.all.map do |category|
      total = total_expenses(@mes_atual, category.id)
      [category.name, total]
    end.reject { |_, total| total.zero? }
       .sort_by { |_, total| -total }
       .to_h

    set_category_details
  end

  def set_category_details
    details = Expense.includes(:category)
                     .where(balance_month: @mes_atual)
                     .group_by { |expense| expense.category.name }
                     .transform_values { |expenses| format_expense_details(expenses) }

    @detalhes_despesas_por_categoria = @despesas_por_categoria.keys.each_with_object({}) do |category, hash|
      hash[category.strip] = details[category]&.presence || []
    end
  end

  def format_expense_details(expenses)
    helper = ActionController::Base.helpers

    expenses.map do |expense|
      amount = helper.number_to_currency(expense.amount, unit: "R$ ", separator: ",", delimiter: ".")

      if expense.payment_method_credito_parcelado?
        "#{expense.description} - Parcela #{expense.current_installment}/#{expense.installments_count} (#{amount})"
      else
        "#{expense.description} (#{amount})"
      end
    end
  end

  def set_monthly_chart_data
    @meses_datas = MONTHS_FOR_CHART.times.map { |i| @hoje - i.months }.reverse
    @meses_labels = @meses_datas.map { |date| date.strftime("%B") }

    @receitas_mensais = @meses_datas.map { |date| data_in_month(Income, date.all_month).sum(:amount) }
    @despesas_mensais = @meses_datas.map { |date| total_expenses(date.all_month) }
  end

  def set_calendar_data
    @calendar_expenses_not_paid = Expense.where(paid: false, date: @calendar_range).includes(:category)
  end

  def set_recent_expenses
    current_month_range = Date.current.all_month

    @recent_expenses = Expense.where(balance_month: current_month_range)
                              .includes(:category)
                              .select(:id, :description, :amount, :date, :category_id)
                              .sort_by(&:date)
                              .last(RECENT_EXPENSES_LIMIT)
  end

  def prepare_calendar_data
    start_date = @calendar_range.begin.beginning_of_week(:sunday)
    end_date = @calendar_range.end.end_of_week(:sunday)
    @calendar_weeks = (start_date..end_date).to_a.in_groups_of(7)

    @daily_expenses = {}

    @calendar_expenses_not_paid.each do |expense|
      @daily_expenses[expense.date] ||= []
      @daily_expenses[expense.date] << {
        amount: expense.amount,
        description: expense.description,
        category_emoji: expense.category&.emoji
      }
    end
  end

  def set_forecast_data
    @months = (1..12).to_a
    @forecast_data = {}

    total_receitas_anteriores = Income.where("balance_month < ?", Date.new(@year, 1, 1)).sum(:amount)
    total_despesas_anteriores = Expense.where("balance_month < ?", Date.new(@year, 1, 1)).sum(:amount)

    @months.each do |month|
      month_range = Date.new(@year, month, 1).all_month
      receitas_mes = Income.where(balance_month: month_range).sum(:amount)
      despesas_mes = Expense.where(balance_month: month_range).sum(:amount)

      saldo_anteriores = total_receitas_anteriores - total_despesas_anteriores
      total_receitas = saldo_anteriores + receitas_mes
      saldo_liquido = total_receitas - despesas_mes

      @forecast_data[month] = {
        receitas: total_receitas,
        despesas: despesas_mes,
        saldo: saldo_liquido
      }

      total_receitas_anteriores += receitas_mes
      total_despesas_anteriores += despesas_mes
    end
  end
end
