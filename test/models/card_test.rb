require "test_helper"

class CardTest < ActiveSupport::TestCase
  setup do
    Expense.delete_all
    Card.delete_all
    Category.delete_all

    @category = Category.create!(name: "Lazer")
  end

  test "normalizes card number before validation" do
    card = Card.create!(
      name: "Visa",
      number: "1234 5678-1234 5678",
      total_limit: 3000,
      due_day: 10,
      closing_day: 5
    )

    assert_equal "1234567812345678", card.number
  end

  test "parses brazilian currency before save" do
    card = Card.create!(
      name: "Master",
      number: "9999888877776666",
      total_limit: "R$ 3.500,75",
      due_day: 10,
      closing_day: 5
    )

    assert_equal 3500.75, card.total_limit.to_f
  end

  test "calculates remaining limit using unpaid expenses in the same table" do
    card = Card.create!(
      name: "Nubank",
      number: "1234567812345678",
      total_limit: 1000,
      due_day: 10,
      closing_day: 5
    )

    Expense.create!(
      amount: 100,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Mercado",
      category: @category,
      card: card,
      payment_method: :credito_a_vista,
      paid: false
    )

    Expense.create!(
      amount: 150,
      date: Date.new(2026, 4, 16),
      balance_month: Date.new(2026, 4, 1),
      description: "Curso",
      category: @category,
      card: card,
      payment_method: :credito_parcelado,
      installments_count: 2,
      current_installment: 1,
      paid: true
    )

    assert_equal 750, card.reload.remaining_limit
  end

  test "calculates billing due date using closing day and due day" do
    card = Card.create!(
      name: "Visa",
      number: "1234567812345678",
      total_limit: 1000,
      due_day: 10,
      closing_day: 20
    )

    assert_equal Date.new(2026, 5, 10), card.billing_due_date_for(Date.new(2026, 4, 20))
    assert_equal Date.new(2026, 6, 10), card.billing_due_date_for(Date.new(2026, 4, 21))
  end

  test "calculates same month billing due date when due day is after closing day" do
    card = Card.create!(
      name: "Master",
      number: "9999888877776666",
      total_limit: 1000,
      due_day: 10,
      closing_day: 5
    )

    assert_equal Date.new(2026, 4, 10), card.billing_due_date_for(Date.new(2026, 4, 5))
    assert_equal Date.new(2026, 5, 10), card.billing_due_date_for(Date.new(2026, 4, 6))
  end
end
