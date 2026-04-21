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
end
