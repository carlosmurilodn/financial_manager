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
      closing_day: 5
    )
  end

  test "should get report" do
    get report_expenses_url

    assert_response :success
  end

  test "invalid turbo stream create renders new expense form" do
    assert_no_difference("Expense.count") do
      post expenses_url(format: :turbo_stream), params: {
        expenses: {
          "0" => {
            amount: "",
            description: "",
            date: "",
            balance_month: "",
            category_id: "",
            payment_method: "",
            card_id: ""
          }
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Nova Despesa"
  end

  test "sorting expenses applies before pagination" do
    11.times do |index|
      Expense.create!(
        amount: index + 1,
        description: "Despesa Ordenavel #{index + 1}",
        date: Date.new(2026, 4, index + 1),
        balance_month: Date.new(2026, 4, 1),
        category: @category,
        payment_method: :pix,
        paid: false
      )
    end

    get expenses_url(sort: "amount", direction: "desc", per_page: 10)

    assert_response :success
    assert_includes response.body, "Despesa Ordenavel 11"
    assert_no_match(/Despesa Ordenavel 1[^0-9]/, response.body)
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
    assert_equal [Date.new(2026, 4, 16)], grouped_expenses.reorder(nil).distinct.pluck(:date)
    assert_equal Date.new(2026, 4, 1), grouped_expenses.first.balance_month
    assert_equal Date.new(2026, 12, 1), grouped_expenses.last.balance_month
  end

  test "creating a credit expense without balance month uses card billing due date" do
    @card.update!(due_day: 10, closing_day: 20)

    assert_difference("Expense.count", 1) do
      post expenses_url, params: {
        expense: {
          amount: "150,00",
          description: "Mercado",
          date: "21/04/2026",
          balance_month: "",
          category_id: @category.id,
          card_id: @card.id,
          payment_method: "credito_a_vista",
          paid: false
        }
      }
    end

    assert_redirected_to expenses_url
    assert_equal Date.new(2026, 6, 10), Expense.order(:id).last.balance_month
  end

  test "creating a non credit expense without balance month uses purchase date" do
    assert_difference("Expense.count", 1) do
      post expenses_url, params: {
        expense: {
          amount: "80,00",
          description: "Padaria",
          date: "21/04/2026",
          balance_month: "",
          category_id: @category.id,
          payment_method: "pix",
          paid: false
        }
      }
    end

    assert_redirected_to expenses_url
    assert_equal Date.new(2026, 4, 21), Expense.order(:id).last.balance_month
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
      },
      update_scope: "single"
    }

    assert_redirected_to expenses_url
    assert_equal 200, future_expense.reload.amount.to_f
    assert_predicate future_expense, :paid?
  end

  test "updating a parcel with group scope propagates shared fields to future parcels" do
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

    patch expense_url(root), params: {
      expense: {
        amount: "200,00",
        description: "Curso Atualizado",
        date: "20/04/2026",
        balance_month: "01/04/2026",
        category_id: root.category_id,
        card_id: root.card_id,
        payment_method: root.payment_method,
        installments_count: root.installments_count,
        current_installment: root.current_installment,
        paid: true
      },
      update_scope: "group"
    }

    assert_redirected_to expenses_url
    assert_equal "Curso Atualizado", future_expense.reload.description
    assert_equal 200, future_expense.amount.to_f
    assert_equal Date.new(2026, 4, 20), future_expense.date
    assert_equal Date.new(2026, 5, 1), future_expense.balance_month
    assert_not future_expense.paid?
  end

  test "updating the first parcel with single scope does not change future parcels" do
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

    patch expense_url(root), params: {
      expense: {
        amount: "210,00",
        description: "Curso Raiz",
        date: "25/04/2026",
        balance_month: "01/04/2026",
        category_id: root.category_id,
        card_id: root.card_id,
        payment_method: root.payment_method,
        installments_count: root.installments_count,
        current_installment: root.current_installment,
        paid: true
      },
      update_scope: "single"
    }

    assert_redirected_to expenses_url
    assert_equal "Curso", future_expense.reload.description
    assert_equal 120, future_expense.amount.to_f
    assert_equal Date.new(2026, 4, 16), future_expense.date
  end

  test "destroying a parcel with single scope removes only that parcel" do
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
    last_expense = Expense.find_by!(installment_group_id: root.id, current_installment: 3)

    assert_difference("Expense.count", -1) do
      delete expense_url(future_expense), params: { delete_scope: "single" }
    end

    assert_redirected_to expenses_url
    assert_predicate root.reload, :persisted?
    assert_raises(ActiveRecord::RecordNotFound) { future_expense.reload }
    assert_predicate last_expense.reload, :persisted?
  end

  test "destroying a parcel with group scope removes that parcel and the next ones" do
    root = Expense.create!(
      amount: 120,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Curso",
      category: @category,
      card: @card,
      payment_method: :credito_parcelado,
      installments_count: 4,
      current_installment: 1,
      paid: false
    )

    second_expense = Expense.find_by!(installment_group_id: root.id, current_installment: 2)

    assert_difference("Expense.count", -3) do
      delete expense_url(second_expense), params: { delete_scope: "group" }
    end

    assert_redirected_to expenses_url
    assert_predicate root.reload, :persisted?
    assert_equal [1], Expense.where(installment_group_id: root.id).pluck(:current_installment)
  end

  test "toggling paid with single scope updates only the selected parcel" do
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
    last_expense = Expense.find_by!(installment_group_id: root.id, current_installment: 3)

    patch toggle_paid_expense_url(future_expense), params: { paid_scope: "single" }

    assert_redirected_to expenses_url
    assert_predicate future_expense.reload, :paid?
    assert_not root.reload.paid?
    assert_not last_expense.reload.paid?
  end

  test "toggling paid with group scope updates the selected parcel and the next ones" do
    root = Expense.create!(
      amount: 120,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Curso",
      category: @category,
      card: @card,
      payment_method: :credito_parcelado,
      installments_count: 4,
      current_installment: 1,
      paid: false
    )

    second_expense = Expense.find_by!(installment_group_id: root.id, current_installment: 2)
    last_expense = Expense.find_by!(installment_group_id: root.id, current_installment: 4)

    patch toggle_paid_expense_url(second_expense), params: { paid_scope: "group" }

    assert_redirected_to expenses_url
    assert_not root.reload.paid?
    assert_predicate second_expense.reload, :paid?
    assert_predicate last_expense.reload, :paid?
  end
end
