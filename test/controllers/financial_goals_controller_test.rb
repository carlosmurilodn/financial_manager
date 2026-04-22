require "test_helper"

class FinancialGoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    FinancialGoal.delete_all
    Expense.delete_all
    Card.delete_all
    Category.delete_all

    @category = Category.create!(name: "Objetivos")
    @card = Card.create!(name: "Cartao Recursos", total_limit: 3_000)
    @financial_goal = FinancialGoal.create!(
      description: "Reserva",
      target_amount: 10_000,
      current_amount: 2_000,
      category: @category,
      due_date: Date.new(2026, 12, 31),
      status: :planned,
      priority: :medium
    )
  end

  test "should get index" do
    get financial_goals_url

    assert_response :success
    assert_includes response.body, "Objetivos"
    assert_includes response.body, @financial_goal.description
    assert_includes response.body, @category.display_name
  end

  test "should get new" do
    get new_financial_goal_url

    assert_response :success
    assert_includes response.body, "Novo Objetivo"
  end

  test "should create financial goal" do
    assert_difference("FinancialGoal.count", 1) do
      post financial_goals_url, params: {
        financial_goal: {
          description: "Viagem",
          target_amount: "R$ 5.500,75",
          current_amount: "R$ 1.000,25",
          category_id: @category.id,
          due_date: "2026-07-01",
          status: "in_progress",
          priority: "high",
          notes: "Comprar passagens",
          financial_goal_resources_attributes: {
            "0" => {
              resource_type: "own_resource",
              description: "Conta investimento",
              amount: "R$ 500,00",
              include_in_total: "1"
            },
            "1" => {
              resource_type: "credit_limit",
              description: "",
              source_id: @card.id,
              amount: "R$ 0,00",
              include_in_total: "1"
            }
          }
        }
      }
    end

    goal = FinancialGoal.order(:id).last

    assert_redirected_to financial_goals_url
    assert_equal "Viagem", goal.description
    assert_equal 5500.75, goal.target_amount.to_f
    assert_equal 1000.25, goal.current_amount.to_f
    assert_equal @category, goal.category
    assert_equal 2, goal.financial_goal_resources.count
    assert_equal 500, goal.own_resources_amount.to_f
    assert_equal @card.remaining_limit, goal.credit_limit_amount.to_f
    assert_predicate goal, :status_in_progress?
    assert_predicate goal, :priority_high?
  end

  test "should update financial goal" do
    patch financial_goal_url(@financial_goal), params: {
      financial_goal: {
        description: "Reserva revisada",
        target_amount: "R$ 12.000,00",
        current_amount: "R$ 4.500,00",
        category_id: @category.id,
        due_date: "2027-01-31",
        status: "paused",
        priority: "low",
        notes: "Aguardar reajuste",
        financial_goal_resources_attributes: {
          "0" => {
            resource_type: "external_resource",
            description: "Valor separado",
            amount: "R$ 2.000,00",
            include_in_total: "1"
          }
        }
      }
    }

    assert_redirected_to financial_goals_url
    assert_equal "Reserva revisada", @financial_goal.reload.description
    assert_equal 12_000, @financial_goal.target_amount.to_f
    assert_equal 4_500, @financial_goal.current_amount.to_f
    assert_equal @category, @financial_goal.category
    assert_equal 1, @financial_goal.financial_goal_resources.count
    assert_equal 2_000, @financial_goal.own_resources_amount.to_f
    assert_predicate @financial_goal, :status_paused?
    assert_predicate @financial_goal, :priority_low?
  end

  test "should destroy financial goal" do
    assert_difference("FinancialGoal.count", -1) do
      delete financial_goal_url(@financial_goal)
    end

    assert_redirected_to financial_goals_url
  end
end
