require "test_helper"

class IncomesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Expense.delete_all
    Income.delete_all
    Card.delete_all
    Category.delete_all
  end

  test "creating an income with repetition creates future monthly incomes" do
    assert_difference("Income.count", 3) do
      post incomes_url, params: {
        income: {
          amount: "2.500,90",
          description: "Salario",
          date: "16/04/2026",
          balance_month: "01/04/2026",
          repetir: 2,
          paid: true
        }
      }
    end

    incomes = Income.order(:balance_month, :date)

    assert_redirected_to incomes_url
    assert_equal [ 2500.9, 2500.9, 2500.9 ], incomes.map { |income| income.amount.to_f }
    assert_equal [ Date.new(2026, 4, 1), Date.new(2026, 5, 1), Date.new(2026, 6, 1) ], incomes.pluck(:balance_month)
    assert_equal [ true, false, false ], incomes.pluck(:paid)
  end

  test "toggle_paid flips the income payment status" do
    income = Income.create!(
      amount: 500,
      description: "Freela",
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      paid: false
    )

    patch toggle_paid_income_url(income)

    assert_redirected_to incomes_url
    assert_predicate income.reload, :paid?
  end
end
