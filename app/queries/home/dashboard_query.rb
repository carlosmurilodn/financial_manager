module Home
  class DashboardQuery
    Result = Struct.new(
      :today,
      :current_month_range,
      :card_balance_month,
      :card_balance_year,
      :card_balance_date,
      :card_balance_range,
      :previous_card_balance_date,
      :next_card_balance_date,
      :category_expense_month,
      :category_expense_year,
      :category_expense_date,
      :category_expense_range,
      :previous_category_expense_date,
      :next_category_expense_date,
      :movement_month,
      :movement_year,
      :movement_date,
      :previous_movement_date,
      :next_movement_date,
      :month,
      :year,
      :calendar_range,
      :current_balance,
      :monthly_incomes,
      :monthly_expenses,
      :net_balance,
      :cards_info,
      :category_expense_summaries,
      :recent_expenses,
      :recent_incomes,
      :calendar_weeks,
      :daily_calendar_items,
      :monthly_agenda_items,
      :months,
      :forecast_data,
      :financial_goals_summary,
      :financial_goals_total_remaining,
      :financial_goals_average_progress,
      keyword_init: true
    )

    def initialize(params:)
      @params = params
      @today = Date.current
      @current_month_range = today.all_month
      @card_balance_period = build_period(:card_month, :card_year)
      @category_expense_period = build_period(:category_month, :category_year)
      @movement_period = build_period(:movement_month, :movement_year)
      @month = (params[:month] || today.month).to_i
      @year = (params[:year] || today.year).to_i
      @calendar_range = Date.new(year, month, 1).all_month
    rescue Date::Error
      @month = today.month
      @year = today.year
      @calendar_range = today.all_month
    end

    def call
      calendar_items = build_calendar_items(calendar_incomes, calendar_expenses)
      financial_goals = financial_goals_summary

      Result.new(
        today: today,
        current_month_range: current_month_range,
        card_balance_month: card_balance_period.month,
        card_balance_year: card_balance_period.year,
        card_balance_date: card_balance_period.date,
        card_balance_range: card_balance_period.range,
        previous_card_balance_date: card_balance_period.previous_date,
        next_card_balance_date: card_balance_period.next_date,
        category_expense_month: category_expense_period.month,
        category_expense_year: category_expense_period.year,
        category_expense_date: category_expense_period.date,
        category_expense_range: category_expense_period.range,
        previous_category_expense_date: category_expense_period.previous_date,
        next_category_expense_date: category_expense_period.next_date,
        movement_month: movement_period.month,
        movement_year: movement_period.year,
        movement_date: movement_period.date,
        previous_movement_date: movement_period.previous_date,
        next_movement_date: movement_period.next_date,
        month: month,
        year: year,
        calendar_range: calendar_range,
        current_balance: current_balance,
        monthly_incomes: data_in_month(Income, current_month_range).sum(:amount),
        monthly_expenses: total_expenses(current_month_range),
        net_balance: Income.sum(:amount) - Expense.effective_sum,
        cards_info: cards_info,
        category_expense_summaries: category_expense_summaries,
        recent_expenses: recent_expenses,
        recent_incomes: recent_incomes,
        calendar_weeks: calendar_weeks,
        daily_calendar_items: calendar_items[:daily_items],
        monthly_agenda_items: calendar_items[:agenda_items],
        months: (1..12).to_a,
        forecast_data: FinancialForecast.for_year(year),
        financial_goals_summary: financial_goals,
        financial_goals_total_remaining: financial_goals.sum(&:remaining_amount),
        financial_goals_average_progress: average_goal_progress(financial_goals)
      )
    end

    private

    Period = Struct.new(:month, :year, :date, :range, :previous_date, :next_date, keyword_init: true)

    attr_reader :params,
                :today,
                :current_month_range,
                :card_balance_period,
                :category_expense_period,
                :movement_period,
                :month,
                :year,
                :calendar_range

    def build_period(month_param, year_param)
      month_value = (params[month_param] || today.month).to_i
      year_value = (params[year_param] || today.year).to_i
      date = Date.new(year_value, month_value, 1)
      period_for(date)
    rescue Date::Error
      period_for(today.beginning_of_month)
    end

    def period_for(date)
      Period.new(
        month: date.month,
        year: date.year,
        date: date,
        range: date.all_month,
        previous_date: date.prev_month,
        next_date: date.next_month
      )
    end

    def data_in_month(model, month_range)
      model.where(balance_month: month_range)
    end

    def total_balance_before(model, date)
      scope = model.where("balance_month <= ?", date.end_of_month).where(paid: true)

      model == Expense ? Expense.effective_sum(scope) : scope.sum(:amount)
    end

    def total_expenses(month_range)
      Expense.effective_sum(Expense.where(balance_month: month_range))
    end

    def current_balance
      total_balance_before(Income, today) - total_balance_before(Expense, today)
    end

    def cards_info
      Card.order(Arel.sql("total_limit DESC NULLS LAST, name ASC")).map do |card|
        committed_amount = unpaid_expenses_from_selected_month(card)
        selected_month_expenses = card_expenses_from_selected_month(card).to_a

        {
          card: card,
          total: committed_amount,
          remaining_limit: remaining_card_limit(card, committed_amount),
          month_total: selected_month_expenses.sum(&:effective_amount),
          month_paid: selected_month_expenses.empty? || selected_month_expenses.all?(&:paid?),
          items: selected_month_expense_items(selected_month_expenses)
        }
      end
    end

    def unpaid_expenses_from_selected_month(card)
      Expense.where(card: card, paid: false)
             .where("balance_month >= ?", card_balance_period.date.beginning_of_month)
             .then { |scope| Expense.effective_sum(scope) }
    end

    def remaining_card_limit(card, committed_amount)
      [ card.total_limit.to_f - committed_amount.to_f, 0 ].max
    end

    def card_expenses_from_selected_month(card)
      Expense.where(card: card, balance_month: card_balance_period.range)
             .order(:date, :description, :id)
    end

    def selected_month_expense_items(expenses)
      expenses.map do |expense|
        {
          date: expense.date,
          description: expense.description.presence || "Despesa",
          amount: expense.effective_amount,
          paid: expense.paid?,
          installment_label: expense.payment_method_credito_parcelado? ? expense.installment_label : nil
        }
      end
    end

    def category_expense_summaries
      expenses = Expense.includes(:category).where(balance_month: category_expense_period.range)
      total_month = expenses.to_a.sum { |expense| expense.effective_amount.abs }.to_f

      expenses.group_by(&:category).map do |category, category_expenses|
        category_expense_summary(category, category_expenses, total_month)
      end.sort_by { |summary| -summary[:total].abs }
    end

    def category_expense_summary(category, category_expenses, total_month)
      total = category_expenses.sum(&:effective_amount).to_f

      {
        name: category&.clean_name || "Sem categoria",
        icon: category&.material_icon || "category",
        color: category&.display_color || Category::COLOR_PALETTE.values.first,
        total: total,
        count: category_expenses.size,
        percent: total_month.positive? ? (total.abs / total_month) * 100 : 0,
        items: category_expense_items(category_expenses)
      }
    end

    def category_expense_items(expenses)
      expenses.sort_by(&:date).map do |expense|
        {
          date: expense.date,
          description: expense.description.presence || "Despesa",
          amount: expense.effective_amount
        }
      end
    end

    def calendar_expenses
      @calendar_expenses ||= Expense.where(date: calendar_range).includes(:category)
    end

    def calendar_incomes
      @calendar_incomes ||= Income.where(date: calendar_range).includes(:category)
    end

    def recent_expenses
      Expense.includes(:category)
             .select(:id, :description, :amount, :date, :balance_month, :category_id, :payment_method, :paid)
             .where(balance_month: movement_period.range)
             .order(date: :asc, id: :desc)
    end

    def recent_incomes
      Income.includes(:category)
            .where(balance_month: movement_period.range)
            .order(balance_month: :asc, date: :desc, id: :desc)
    end

    def calendar_weeks
      start_date = calendar_range.begin.beginning_of_week(:sunday)
      end_date = calendar_range.end.end_of_week(:sunday)

      (start_date..end_date).to_a.in_groups_of(7)
    end

    def build_calendar_items(incomes, expenses)
      daily_items = {}
      agenda_items = []

      incomes.each { |income| append_calendar_income(daily_items, agenda_items, income) }
      expenses.each { |expense| append_calendar_expense(daily_items, agenda_items, expense) }

      agenda_items.sort_by! { |item| [ item[:date], item[:type] == :expense ? 0 : 1, item[:description] ] }
      { daily_items: daily_items, agenda_items: agenda_items }
    end

    def append_calendar_income(daily_items, agenda_items, income)
      daily_items[income.date] ||= { incomes: [], expenses: [] }
      daily_items[income.date][:incomes] << {
        amount: income.amount,
        description: calendar_income_description(income)
      }

      agenda_items << {
        date: income.date,
        type: :income,
        description: calendar_income_description(income),
        amount: income.amount
      }
    end

    def append_calendar_expense(daily_items, agenda_items, expense)
      daily_items[expense.date] ||= { incomes: [], expenses: [] }
      daily_items[expense.date][:expenses] << {
        amount: expense.effective_amount,
        description: calendar_expense_description(expense)
      }

      agenda_items << {
        date: expense.date,
        type: :expense,
        description: calendar_expense_description(expense),
        amount: expense.effective_amount
      }
    end

    def calendar_income_description(income)
      [ income.category&.clean_name, income.description.presence || "Receita" ].compact.join(" - ")
    end

    def calendar_expense_description(expense)
      [ expense.category&.clean_name, expense.description.presence || "Despesa" ].compact.join(" - ")
    end

    def financial_goals_summary
      FinancialGoal.includes(:category, :financial_goal_resources).to_a.sort_by do |goal|
        [
          -goal.progress_percent,
          goal.remaining_amount,
          -goal.priority_before_type_cast.to_i,
          goal.due_date || Date.new(9999, 12, 31),
          goal.description.to_s
        ]
      end
    end

    def average_goal_progress(goals)
      return 0 if goals.empty?

      goals.sum(&:progress_percent) / goals.size
    end
  end
end
