require "test_helper"

class CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Expense.delete_all
    Card.delete_all
    Category.delete_all
    User.delete_all

    @user = User.create!(
      email: "teste@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    sign_in @user

    @category = Category.create!(
      name: "Compras",
      icon: "shopping_cart",
      user: @user
    )

    @card = Card.create!(
      name: "Cartao Teste",
      number: "1234567812345678",
      total_limit: 5000,
      due_day: 10,
      closing_day: 5,
      user: @user
    )
  end

  test "creating a card normalizes currency and redirects" do
    assert_difference("Card.count", 1) do
      post cards_url, params: {
        card: {
          name: "Nubank",
          number: "9999 8888 7777 6666",
          total_limit: "R$ 3.500,75",
          due_day: 15,
          closing_day: 7
        }
      }
    end

    card = Card.order(:id).last

    assert_redirected_to cards_url
    assert_equal @user, card.user
    assert_equal 3500.75, card.total_limit.to_f
    assert_equal "9999888877776666", card.number
  end

  test "creating a card attaches an icon" do
    uploaded_icon = Rack::Test::UploadedFile.new(file_fixture("card_icon.txt"), "text/plain")

    assert_difference("Card.count", 1) do
      post cards_url, params: {
        card: {
          name: "Inter",
          number: "1234 5678 1234 5678",
          total_limit: "R$ 1.000,00",
          due_day: 15,
          closing_day: 7,
          icon: uploaded_icon
        }
      }
    end

    card = Card.order(:id).last

    assert_redirected_to cards_url
    assert_equal @user, card.user
    assert_predicate card.icon, :attached?
  end

  test "updating a card can remove the attached icon" do
    @card.icon.attach(
      io: file_fixture("card_icon.txt").open,
      filename: "card_icon.txt",
      content_type: "text/plain"
    )

    patch card_url(@card), params: {
      card: {
        name: @card.name,
        number: @card.number,
        total_limit: "R$ 5.000,00",
        due_day: @card.due_day,
        closing_day: @card.closing_day,
        remove_icon: "1"
      }
    }

    assert_redirected_to cards_url
    assert_not @card.reload.icon.attached?
  end

  test "index filters cards by debt description and balance month" do
    other_card = Card.create!(
      name: "Cartao Viagem",
      number: "8765432187654321",
      total_limit: 3000,
      due_day: 15,
      closing_day: 10,
      user: @user
    )

    Expense.create!(
      amount: 300,
      date: Date.new(2026, 3, 2),
      balance_month: Date.new(2026, 3, 1),
      description: "Notebook",
      category: @category,
      card: @card,
      payment_method: :credito_a_vista,
      paid: false,
      user: @user
    )

    Expense.create!(
      amount: 120,
      date: Date.new(2025, 7, 10),
      balance_month: Date.new(2025, 7, 1),
      description: "Hotel",
      category: @category,
      card: other_card,
      payment_method: :credito_a_vista,
      paid: false,
      user: @user
    )

    Expense.create!(
      amount: 90,
      date: Date.new(2024, 1, 5),
      balance_month: Date.new(2024, 1, 1),
      description: "Divida paga",
      category: @category,
      card: other_card,
      payment_method: :credito_a_vista,
      paid: true,
      user: @user
    )

    get cards_url, params: { description: "note", month: 3, year: 2026 }

    assert_response :success
    assert_includes response.body, "Cartao Teste"
    refute_includes response.body, "Cartao Viagem"
    assert_select "select[name='year'] option", text: "2026"
    assert_select "select[name='year'] option", text: "2025"
    assert_select "select[name='year'] option", text: "2024", count: 0
  end

  test "index can filter by card name with balance month" do
    Expense.create!(
      amount: 300,
      date: Date.new(2026, 3, 2),
      balance_month: Date.new(2026, 3, 1),
      description: "Compra qualquer",
      category: @category,
      card: @card,
      payment_method: :credito_a_vista,
      paid: false,
      user: @user
    )

    get cards_url, params: { description: "teste", month: 3, year: 2026 }

    assert_response :success
    assert_includes response.body, "Cartao Teste"
  end

  test "clear filters redirects to cards index" do
    delete clear_filters_cards_url

    assert_redirected_to cards_url
  end

  test "pay marks current month credit expenses as paid" do
    current_month = Date.current.beginning_of_month
    next_month = current_month.next_month

    credit_expense = Expense.create!(
      amount: 100,
      date: current_month + 5.days,
      balance_month: current_month,
      description: "Mercado",
      category: @category,
      card: @card,
      payment_method: :credito_a_vista,
      paid: false,
      user: @user
    )

    parcelled_expense = Expense.create!(
      amount: 200,
      date: current_month + 3.days,
      balance_month: current_month,
      description: "Curso",
      category: @category,
      card: @card,
      payment_method: :credito_parcelado,
      installments_count: 2,
      current_installment: 1,
      paid: false,
      user: @user
    )

    generated_future_expense = Expense.find_by!(
      installment_group_id: parcelled_expense.id,
      current_installment: 2
    )

    future_expense = Expense.create!(
      amount: 90,
      date: next_month + 5.days,
      balance_month: next_month,
      description: "Assinatura",
      category: @category,
      card: @card,
      payment_method: :credito_a_vista,
      paid: false,
      user: @user
    )

    patchless_expense = Expense.create!(
      amount: 40,
      date: current_month + 1.day,
      balance_month: current_month,
      description: "Debito",
      category: @category,
      card: @card,
      payment_method: :debito,
      paid: false,
      user: @user
    )

    post pay_card_url(@card)

    assert_redirected_to cards_url
    assert_predicate credit_expense.reload, :paid?
    assert_predicate parcelled_expense.reload, :paid?
    assert_not generated_future_expense.reload.paid?
    assert_not future_expense.reload.paid?
    assert_not patchless_expense.reload.paid?
  end
end