require "test_helper"

class FinancialForecastTest < ActiveSupport::TestCase
  test "keeps monthly incomes separate from accumulated balance" do
    year = 2032
    category = Category.create!(name: "Forecast test")

    Income.create!(
      amount: 100,
      date: Date.new(year - 1, 12, 20),
      balance_month: Date.new(year - 1, 12, 1),
      description: "Previous income"
    )
    Expense.create!(
      amount: 40,
      date: Date.new(year - 1, 12, 21),
      balance_month: Date.new(year - 1, 12, 1),
      description: "Previous expense",
      category: category,
      payment_method: :pix
    )
    Income.create!(
      amount: 30,
      date: Date.new(year, 1, 5),
      balance_month: Date.new(year, 1, 1),
      description: "January income"
    )
    Expense.create!(
      amount: 10,
      date: Date.new(year, 1, 6),
      balance_month: Date.new(year, 1, 1),
      description: "January expense",
      category: category,
      payment_method: :pix
    )

    forecast = FinancialForecast.for_year(year)

    assert_equal 30, forecast[1][:receitas]
    assert_equal 10, forecast[1][:despesas]
    assert_equal 80, forecast[1][:saldo]
  end
end
