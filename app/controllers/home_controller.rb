class HomeController < ApplicationController
  def index
    assign_dashboard_result(Home::DashboardQuery.new(params: params).call)
  end

  private

  def assign_dashboard_result(result)
    assign_periods(result)
    assign_kpis(result)
    assign_dashboard_lists(result)
    assign_planning_data(result)
  end

  def assign_periods(result)
    @hoje = result.today
    @mes_atual = result.current_month_range
    @card_balance_month = result.card_balance_month
    @card_balance_year = result.card_balance_year
    @card_balance_date = result.card_balance_date
    @card_balance_range = result.card_balance_range
    @previous_card_balance_date = result.previous_card_balance_date
    @next_card_balance_date = result.next_card_balance_date
    @category_expense_month = result.category_expense_month
    @category_expense_year = result.category_expense_year
    @category_expense_date = result.category_expense_date
    @category_expense_range = result.category_expense_range
    @previous_category_expense_date = result.previous_category_expense_date
    @next_category_expense_date = result.next_category_expense_date
    @month = result.month
    @year = result.year
    @calendar_range = result.calendar_range
  end

  def assign_kpis(result)
    @saldo_atual = result.current_balance
    @receitas_mes = result.monthly_incomes
    @despesas_mes = result.monthly_expenses
    @saldo_liquido = result.net_balance
  end

  def assign_dashboard_lists(result)
    @cards_info = result.cards_info
    @category_expense_summaries = result.category_expense_summaries
    @recent_expenses = result.recent_expenses
    @recent_incomes = result.recent_incomes
    @calendar_weeks = result.calendar_weeks
    @daily_calendar_items = result.daily_calendar_items
    @monthly_agenda_items = result.monthly_agenda_items
  end

  def assign_planning_data(result)
    @months = result.months
    @forecast_data = result.forecast_data
    @financial_goals_summary = result.financial_goals_summary
    @financial_goals_total_remaining = result.financial_goals_total_remaining
    @financial_goals_average_progress = result.financial_goals_average_progress
  end
end
