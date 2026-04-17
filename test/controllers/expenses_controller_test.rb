require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  fixtures

  setup do
    Expense.delete_all
    Card.delete_all
    Category.delete_all

    @category = Category.create!(name: "Moradia")
    @card = Card.create!(
      name: "Cartao Teste",
      number: "1234567812345678",
      total_limit: 5000,
      due_day: 10,
      best_day: 5
    )
  end

  test "should get report" do
    get report_expenses_url

    assert_response :success
  end

  test "creating a parcelled expense from an arbitrary current installment generates grouped expenses" do
    previous_ids = Expense.pluck(:id)

    assert_difference("Expense.count", 9) do
      post expenses_url, params: {
        expense: {
          amount: "150,00",
          description: "Notebook",
          date: "16/04/2026",
          balance_month: "01/04/2026",
          category_id: @category.id,
          card_id: @card.id,
          payment_method: "credito_parcelado",
          installments_count: 12,
          current_installment: 4,
          paid: false
        }
      }
    end

    root_expense = Expense.where.not(id: previous_ids).find_by(current_installment: 4)
    grouped_expenses = Expense.where(installment_group_id: root_expense.id).order(:current_installment)

    assert_redirected_to expenses_url
    assert_equal (4..12).to_a, grouped_expenses.pluck(:current_installment)
    assert_equal Date.new(2026, 4, 1), grouped_expenses.first.balance_month
    assert_equal Date.new(2026, 12, 1), grouped_expenses.last.balance_month
  end

  test "creating an expense with repetition creates future monthly expenses" do
    assert_difference("Expense.count", 3) do
      post expenses_url, params: {
        expense: {
          amount: "90,00",
          description: "Academia",
          date: "16/04/2026",
          balance_month: "01/04/2026",
          category_id: @category.id,
          payment_method: "pix",
          repetir: 2,
          paid: false
        }
      }
    end

    repeated_expenses = Expense.order(:balance_month, :date)

    assert_redirected_to expenses_url
    assert_equal [Date.new(2026, 4, 1), Date.new(2026, 5, 1), Date.new(2026, 6, 1)], repeated_expenses.pluck(:balance_month)
    assert_equal [false, false, false], repeated_expenses.pluck(:paid)
  end

  test "updating a generated parcel uses the expense flow" do
    root = Expense.create!(
      amount: 120,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Curso",
      category: @category,
      card: @card,
      payment_method: :credito_parcelado,
      installments_count: 3,
      current_installment: 1,
      paid: false
    )

    future_expense = Expense.find_by!(installment_group_id: root.id, current_installment: 2)

    patch expense_url(future_expense), params: {
      expense: {
        amount: "200,00",
        description: future_expense.description,
        date: "16/05/2026",
        balance_month: "01/05/2026",
        category_id: future_expense.category_id,
        card_id: future_expense.card_id,
        payment_method: future_expense.payment_method,
        installments_count: future_expense.installments_count,
        current_installment: future_expense.current_installment,
        paid: true
      }
    }

    assert_redirected_to expenses_url
    assert_equal 200, future_expense.reload.amount.to_f
    assert_predicate future_expense, :paid?
  end
end
