require "test_helper"

class FinancialGoalTest < ActiveSupport::TestCase
  test "is valid with required fields" do
    goal = FinancialGoal.new(
      description: "Reserva de emergencia",
      target_amount: 10_000,
      current_amount: 1_000,
      due_date: Date.new(2026, 12, 31)
    )

    assert_predicate goal, :valid?
  end

  test "defaults to planned status and medium priority" do
    goal = FinancialGoal.new(
      description: "Viagem",
      target_amount: 5_000,
      due_date: Date.new(2026, 7, 1)
    )

    assert_predicate goal, :status_planned?
    assert_predicate goal, :priority_medium?
  end

  test "is invalid without required fields" do
    goal = FinancialGoal.new

    assert_not goal.valid?
    assert goal.errors[:description].any?
    assert goal.errors[:target_amount].any?
    assert goal.errors[:due_date].any?
  end

  test "requires positive target amount" do
    goal = FinancialGoal.new(
      description: "Objetivo invalido",
      target_amount: 0,
      due_date: Date.new(2026, 12, 31)
    )

    assert_not goal.valid?
    assert goal.errors[:target_amount].any?
  end

  test "calculates progress and remaining amount" do
    goal = FinancialGoal.new(
      description: "Reserva",
      target_amount: 10_000,
      current_amount: 2_500,
      due_date: Date.new(2026, 12, 31)
    )

    assert_equal 25.0, goal.progress_percent
    assert_equal 7_500, goal.remaining_amount
  end

  test "calculates monthly required amount until due date" do
    goal = FinancialGoal.new(
      description: "Viagem",
      target_amount: 12_000,
      current_amount: 3_000,
      due_date: Date.new(2026, 12, 31)
    )

    assert_equal 1_000, goal.monthly_required_amount(Date.new(2026, 4, 21))
  end

  test "uses own resources for progress and keeps credit as potential amount" do
    goal = FinancialGoal.create!(
      description: "Entrada",
      target_amount: 20_000,
      current_amount: 1_000,
      due_date: Date.new(2027, 12, 31)
    )

    goal.financial_goal_resources.create!(
      resource_type: :own_resource,
      description: "Conta corrente",
      amount: 3_000
    )
    goal.financial_goal_resources.create!(
      resource_type: :external_resource,
      description: "Ajuda familiar",
      amount: 2_000
    )
    goal.financial_goal_resources.create!(
      resource_type: :credit_limit,
      description: "Cartao",
      amount: 5_000
    )

    assert_equal 5_000, goal.own_resources_amount
    assert_equal 5_000, goal.credit_limit_amount
    assert_equal 10_000, goal.potential_amount
    assert_equal 25.0, goal.progress_percent
    assert_equal 15_000, goal.remaining_amount
  end
end
