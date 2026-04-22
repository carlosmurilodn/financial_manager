require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "shows selected month card balance as negative when any card expense is unpaid" do
    year = 2033
    card = Card.create!(name: "A Test Card", total_limit: 1_000)
    category = Category.create!(name: "Card balance")

    Expense.create!(
      amount: 120,
      date: Date.new(year, 1, 10),
      balance_month: Date.new(year, 1, 1),
      description: "Open card bill",
      category: category,
      card: card,
      payment_method: :credito_a_vista,
      paid: false
    )

    get root_url(card_month: 1, card_year: year)

    assert_response :success
    assert_includes response.body, "Saldo do mes"
    assert_includes response.body, "is-negative"
  end

  test "shows selected month card balance as positive when all card expenses are paid" do
    year = 2034
    card = Card.create!(name: "A Paid Test Card", total_limit: 1_000)
    category = Category.create!(name: "Paid card balance")

    Expense.create!(
      amount: 80,
      date: Date.new(year, 2, 10),
      balance_month: Date.new(year, 2, 1),
      description: "Paid card bill",
      category: category,
      card: card,
      payment_method: :credito_a_vista,
      paid: true
    )

    get root_url(card_month: 2, card_year: year)

    assert_response :success
    assert_includes response.body, "Saldo do mes"
    assert_includes response.body, "is-positive"
  end

  test "shows all cards ordered by total limit descending" do
    Card.delete_all

    Card.create!(name: "Small Limit Card", total_limit: 100)
    Card.create!(name: "Large Limit Card", total_limit: 1_000)
    Card.create!(name: "Medium Limit Card", total_limit: 500)
    Card.create!(name: "Extra Card 1", total_limit: 90)
    Card.create!(name: "Extra Card 2", total_limit: 80)
    Card.create!(name: "Extra Card 3", total_limit: 70)

    get root_url

    assert_response :success
    assert_includes response.body, "Extra Card 3"
    assert_operator response.body.index("Large Limit Card"), :<, response.body.index("Medium Limit Card")
    assert_operator response.body.index("Medium Limit Card"), :<, response.body.index("Small Limit Card")
  end

  test "shows active financial goals summary on dashboard" do
    FinancialGoal.delete_all
    category = Category.create!(name: "Cursos")

    FinancialGoal.create!(
      description: "Entrada do imovel",
      target_amount: 50_000,
      current_amount: 15_000,
      category: category,
      due_date: Date.current.next_year,
      status: :in_progress,
      priority: :high
    )

    get root_url

    assert_response :success
    assert_includes response.body, "Objetivos"
    assert_includes response.body, "Entrada do imovel"
    assert_includes response.body, "Progresso medio"
    assert_includes response.body, "Cursos"
    assert_includes response.body, "menu_book"
  end
end
