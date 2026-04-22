require "test_helper"

class FinancialGoalResourceTest < ActiveSupport::TestCase
  test "is valid with required fields" do
    goal = FinancialGoal.create!(
      description: "Reserva",
      target_amount: 10_000,
      due_date: Date.new(2026, 12, 31)
    )

    resource = goal.financial_goal_resources.build(
      resource_type: :own_resource,
      description: "Conta investimento",
      amount: 1_500
    )

    assert_predicate resource, :valid?
  end

  test "requires description and non negative amount" do
    resource = FinancialGoalResource.new(amount: -1)

    assert_not resource.valid?
    assert resource.errors[:description].any?
    assert resource.errors[:amount].any?
  end

  test "uses linked card remaining limit as effective amount for credit resource" do
    category = Category.create!(name: "Objetivo cartao")
    card = Card.create!(name: "Cartao objetivo", total_limit: 2_000)
    goal = FinancialGoal.create!(
      description: "Viagem",
      target_amount: 5_000,
      due_date: Date.new(2027, 7, 1)
    )

    Expense.create!(
      amount: 350,
      date: Date.new(2026, 4, 10),
      balance_month: Date.new(2026, 4, 1),
      description: "Compra aberta",
      category: category,
      card: card,
      payment_method: :credito_a_vista,
      paid: false
    )

    resource = goal.financial_goal_resources.create!(
      resource_type: :credit_limit,
      source: card,
      amount: 0
    )

    assert_equal "Card", resource.source_type
    assert_equal 1_650, resource.effective_amount
    assert_equal 1_650, goal.credit_limit_amount
  end
end
