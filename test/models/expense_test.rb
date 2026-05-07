require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
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

  test "is invalid without card for credit payments" do
    expense = Expense.new(
      amount: 120,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Supermercado",
      category: @category,
      payment_method: :credito_a_vista
    )

    assert_not expense.valid?
    assert expense.errors[:card_id].any?
  end

  test "sets repetir to zero by default" do
    expense = Expense.new(
      amount: 50,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Cafe",
      category: @category,
      payment_method: :pix
    )

    expense.valid?

    assert_equal 0, expense.repetir
  end

  test "creates remaining future expenses in the same installment group" do
    expense = Expense.create!(
      amount: 200,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Notebook",
      category: @category,
      card: @card,
      payment_method: :credito_parcelado,
      installments_count: 12,
      current_installment: 4,
      paid: false
    )

    grouped_expenses = Expense.where(installment_group_id: expense.reload.id).order(:current_installment)

    assert_equal expense.id, expense.installment_group_id
    assert_equal (4..12).to_a, grouped_expenses.pluck(:current_installment)
    assert_equal [ 12 ], grouped_expenses.reorder(nil).distinct.pluck(:installments_count)
    assert_equal [ Date.new(2026, 4, 16) ], grouped_expenses.reorder(nil).distinct.pluck(:date)
    assert_equal Date.new(2026, 12, 1), grouped_expenses.last.balance_month
  end

  test "is invalid when current installment exceeds total installments" do
    expense = Expense.new(
      amount: 200,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Notebook",
      category: @category,
      card: @card,
      payment_method: :credito_parcelado,
      installments_count: 3,
      current_installment: 4,
      paid: false
    )

    assert_not expense.valid?
    assert expense.errors[:current_installment].any?
  end
end
