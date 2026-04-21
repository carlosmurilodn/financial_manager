class FinancialForecast
  def self.for_year(year)
    new(year).monthly
  end

  def initialize(year)
    @year = year.to_i
  end

  def monthly
    accumulated_balance = balance_before_year

    (1..12).each_with_object({}) do |month, forecast_data|
      month_range = Date.new(@year, month, 1).all_month
      monthly_incomes = Income.where(balance_month: month_range).sum(:amount)
      monthly_expenses = Expense.where(balance_month: month_range).sum(:amount)

      accumulated_balance += monthly_incomes - monthly_expenses

      forecast_data[month] = {
        receitas: monthly_incomes,
        despesas: monthly_expenses,
        saldo: accumulated_balance
      }
    end
  end

  private

  def balance_before_year
    start_of_year = Date.new(@year, 1, 1)

    Income.where("balance_month < ?", start_of_year).sum(:amount) -
      Expense.where("balance_month < ?", start_of_year).sum(:amount)
  end
end
