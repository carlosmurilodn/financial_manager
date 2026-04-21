require "test_helper"

class CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Expense.delete_all
    Card.delete_all
    Category.delete_all

    @category = Category.create!(name: "Compras")
    @card = Card.create!(
      name: "Cartao Teste",
      number: "1234567812345678",
      total_limit: 5000,
      due_day: 10,
      closing_day: 5
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
      paid: false
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
      paid: false
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
      paid: false
    )

    patchless_expense = Expense.create!(
      amount: 40,
      date: current_month + 1.day,
      balance_month: current_month,
      description: "Debito",
      category: @category,
      card: @card,
      payment_method: :debito,
      paid: false
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
