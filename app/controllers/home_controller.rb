class HomeController < ApplicationController
  def index
    set_current_dates
    calculate_kpis
    set_card_balances
    set_category_expenses_data
    set_calendar_data
    set_recent_expenses
    set_recent_incomes
    prepare_calendar_data
    set_forecast_data
    set_financial_goals_data
  end

  private

  def set_current_dates
    @hoje = Date.current
    @mes_atual = @hoje.all_month
    set_card_balance_period
    set_category_expense_period
    @month = (params[:month] || @hoje.month).to_i
    @year = (params[:year] || @hoje.year).to_i
    start_date = Date.new(@year, @month, 1)
    @calendar_range = start_date.all_month
  end

  def set_card_balance_period
    @card_balance_month = (params[:card_month] || @hoje.month).to_i
    @card_balance_year = (params[:card_year] || @hoje.year).to_i
    @card_balance_date = Date.new(@card_balance_year, @card_balance_month, 1)
    @card_balance_range = @card_balance_date.all_month
    @previous_card_balance_date = @card_balance_date.prev_month
    @next_card_balance_date = @card_balance_date.next_month
  rescue Date::Error
    @card_balance_month = @hoje.month
    @card_balance_year = @hoje.year
    @card_balance_date = @hoje.beginning_of_month
    @card_balance_range = @card_balance_date.all_month
    @previous_card_balance_date = @card_balance_date.prev_month
    @next_card_balance_date = @card_balance_date.next_month
  end

  def set_category_expense_period
    @category_expense_month = (params[:category_month] || @hoje.month).to_i
    @category_expense_year = (params[:category_year] || @hoje.year).to_i
    @category_expense_date = Date.new(@category_expense_year, @category_expense_month, 1)
    @category_expense_range = @category_expense_date.all_month
    @previous_category_expense_date = @category_expense_date.prev_month
    @next_category_expense_date = @category_expense_date.next_month
  rescue Date::Error
    @category_expense_month = @hoje.month
    @category_expense_year = @hoje.year
    @category_expense_date = @hoje.beginning_of_month
    @category_expense_range = @category_expense_date.all_month
    @previous_category_expense_date = @category_expense_date.prev_month
    @next_category_expense_date = @category_expense_date.next_month
  end

  def data_in_month(model, month_range)
    model.where(balance_month: month_range)
  end

  def total_balance_before(model, date)
    model.where("balance_month <= ?", date.end_of_month).where(paid: true).sum(:amount)
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

  # def set_card_balances
  #   @cards_info = Card.order(Arel.sql("due_day IS NULL, due_day ASC, name ASC")).map do |card|
  #     total = accumulated_card_expenses(card)

  #     {
  #       card: card,
  #       total: total,
  #       remaining_limit: [card.total_limit.to_f - total.to_f, 0].max
  #     }
  #   end
  # end

  # def accumulated_card_expenses(card)
  #   expenses = Expense.where(card: card)
  #                     .where("balance_month <= ?", @card_balance_range.end)

  #   expenses = expenses.where(paid: true) unless future_card_balance_period?

  #   expenses.sum(:amount)
  # end

  # def future_card_balance_period?
  #   @card_balance_date > @hoje.beginning_of_month
  # end

  def set_card_balances
    @cards_info = Card.order(Arel.sql("total_limit DESC NULLS LAST, name ASC")).map do |card|
      committed_amount = unpaid_expenses_from_selected_month(card)
      selected_month_expenses = card_expenses_from_selected_month(card).to_a
      selected_month_total = selected_month_expenses.sum(&:amount)
      selected_month_paid = selected_month_expenses.empty? || selected_month_expenses.all?(&:paid?)

      {
        card: card,
        total: committed_amount,
        remaining_limit: [ card.total_limit.to_f - committed_amount.to_f, 0 ].max,
        month_total: selected_month_total,
        month_paid: selected_month_paid,
        items: selected_month_expenses.map do |expense|
          {
            date: expense.date,
            description: expense.description.presence || "Despesa",
            amount: expense.amount,
            paid: expense.paid?,
            installment_label: expense.payment_method_credito_parcelado? ? expense.installment_label : nil
          }
        end
      }
    end
  end

  def unpaid_expenses_from_selected_month(card)
    Expense.where(card: card, paid: false)
          .where("balance_month >= ?", @card_balance_date.beginning_of_month)
          .sum(:amount)
  end

  def card_expenses_from_selected_month(card)
    Expense.where(card: card, balance_month: @card_balance_range)
           .order(:date, :description, :id)
  end

  def set_category_expenses_data
    expenses = Expense.includes(:category).where(balance_month: @category_expense_range)
    total_month = expenses.sum(:amount).to_f

    @category_expense_summaries = expenses.group_by(&:category).map do |category, category_expenses|
      total = category_expenses.sum(&:amount).to_f

      {
        name: category&.clean_name || "Sem categoria",
        icon: category&.material_icon || "category",
        total: total,
        count: category_expenses.size,
        percent: total_month.positive? ? (total / total_month) * 100 : 0,
        items: category_expenses.sort_by(&:date).map do |expense|
          {
            date: expense.date,
            description: expense.description.presence || "Despesa",
            amount: expense.amount
          }
        end
      }
    end.sort_by { |summary| -summary[:total] }
  end

  def set_calendar_data
    @calendar_expenses = Expense.where(date: @calendar_range).includes(:category)
    @calendar_incomes = Income.where(date: @calendar_range).includes(:category)
  end

  def set_recent_expenses
    @recent_expenses = Expense.includes(:category)
                              .select(:id, :description, :amount, :date, :balance_month, :category_id)
                              .where("date >= ?", @hoje.beginning_of_month)
                              .order(date: :asc, id: :desc)
  end

  def set_recent_incomes
    @recent_incomes = Income.includes(:category)
                            .where("balance_month >= ?", @hoje.beginning_of_month)
                            .order(balance_month: :asc, date: :desc, id: :desc)
  end

  def prepare_calendar_data
    start_date = @calendar_range.begin.beginning_of_week(:sunday)
    end_date = @calendar_range.end.end_of_week(:sunday)
    @calendar_weeks = (start_date..end_date).to_a.in_groups_of(7)

    @daily_calendar_items = {}
    @monthly_agenda_items = []

    @calendar_incomes.each do |income|
      @daily_calendar_items[income.date] ||= { incomes: [], expenses: [] }
      @daily_calendar_items[income.date][:incomes] << {
        amount: income.amount,
        description: [ income.category&.clean_name, income.description.presence || "Receita" ].compact.join(" - ")
      }

      @monthly_agenda_items << {
        date: income.date,
        type: :income,
        description: [ income.category&.clean_name, income.description.presence || "Receita" ].compact.join(" - "),
        amount: income.amount
      }
    end

    @calendar_expenses.each do |expense|
      @daily_calendar_items[expense.date] ||= { incomes: [], expenses: [] }
      @daily_calendar_items[expense.date][:expenses] << {
        amount: expense.amount,
        description: [ expense.category&.clean_name, expense.description.presence || "Despesa" ].compact.join(" - ")
      }

      @monthly_agenda_items << {
        date: expense.date,
        type: :expense,
        description: [ expense.category&.clean_name, expense.description.presence || "Despesa" ].compact.join(" - "),
        amount: expense.amount
      }
    end

    @monthly_agenda_items.sort_by! { |item| [ item[:date], item[:type] == :expense ? 0 : 1, item[:description] ] }
  end

  def set_forecast_data
    @months = (1..12).to_a
    @forecast_data = FinancialForecast.for_year(@year)
  end

  def set_financial_goals_data
    active_statuses = [
      FinancialGoal.statuses[:in_progress],
      FinancialGoal.statuses[:planned]
    ]

    goals = FinancialGoal.includes(:category, :financial_goal_resources)
                         # .where(status: active_statuses)
                         .to_a

    @financial_goals_summary = goals.sort_by do |goal|
      [
        -goal.progress_percent,
        goal.remaining_amount,
        -goal.priority_before_type_cast.to_i,
        goal.due_date || Date.new(9999, 12, 31),
        goal.description.to_s
      ]
    end

    @financial_goals_total_remaining = goals.sum(&:remaining_amount)
    @financial_goals_average_progress = if goals.any?
      goals.sum(&:progress_percent) / goals.size
    else
      0
    end
  end
end
