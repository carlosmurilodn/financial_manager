require "test_helper"

class IncomeTest < ActiveSupport::TestCase
  test "is invalid without required fields" do
    income = Income.new

    assert_not income.valid?
    assert income.errors[:amount].any?
    assert income.errors[:date].any?
    assert income.errors[:balance_month].any?
  end

  test "defaults paid to true" do
    income = Income.new(
      amount: 1500,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1)
    )

    assert_predicate income, :paid?
  end

  test "accepts a positive amount" do
    income = Income.new(
      amount: 1500,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Salario"
    )

    assert_predicate income, :valid?
  end
end
