require "rails_helper"

RSpec.describe Expenses::IndexQuery do
  describe "#call" do
    it "filters expenses and calculates effective totals" do
      user = create(:user)
      other_user = create(:user)
      category = create(:category)
      other_category = create(:category)
      card = create(:card, user: user)
      other_card = create(:card, user: user)

      matching_expense = create(
        :expense,
        :card_payment,
        :paid,
        user: user,
        category: category,
        card: card,
        description: "Mercado mensal",
        amount: 150,
        balance_month: Date.new(2026, 6, 1)
      )
      matching_refund = create(
        :expense,
        :refund,
        :paid,
        user: user,
        category: category,
        card: card,
        description: "Mercado estorno",
        amount: 50,
        balance_month: Date.new(2026, 6, 1)
      )
      create(
        :expense,
        :card_payment,
        :paid,
        user: user,
        category: other_category,
        card: card,
        description: "Mercado outra categoria",
        amount: 300,
        balance_month: Date.new(2026, 6, 1)
      )
      create(
        :expense,
        :card_payment,
        :paid,
        user: user,
        category: category,
        card: other_card,
        description: "Mercado outro cartao",
        amount: 250,
        balance_month: Date.new(2026, 6, 1)
      )
      create(
        :expense,
        :card_payment,
        user: user,
        category: category,
        card: card,
        description: "Mercado pendente",
        amount: 200,
        balance_month: Date.new(2026, 6, 1),
        paid: false
      )
      create(
        :expense,
        :card_payment,
        :paid,
        user: other_user,
        category: category,
        description: "Mercado outro usuario",
        amount: 900,
        balance_month: Date.new(2026, 6, 1)
      )

      result = described_class.new(
        user: user,
        filters: {
          month: 6,
          year: 2026,
          category_id: category.id,
          payment_method: nil,
          card_id: card.id,
          paid: "true",
          description: "mercado"
        }
      ).call

      expect(result.expenses).to contain_exactly(matching_expense, matching_refund)
      expect(result.total_amount).to eq(100.to_d)
      expect(result.total_paid).to eq(100.to_d)
      expect(result.total_unpaid).to eq(0.to_d)
    end

    it "calculates previous and net balances for the selected period" do
      user = create(:user)

      create(:income, user: user, amount: 1_000, balance_month: Date.new(2026, 5, 1), paid: true)
      create(:expense, user: user, amount: 300, balance_month: Date.new(2026, 5, 1), paid: false)
      create(:income, user: user, amount: 500, balance_month: Date.new(2026, 6, 1), paid: true)
      create(:income, user: user, amount: 200, balance_month: Date.new(2026, 6, 1), paid: false)
      create(:expense, :paid, user: user, amount: 150, balance_month: Date.new(2026, 6, 1))
      create(:expense, user: user, amount: 80, balance_month: Date.new(2026, 6, 1), paid: false)

      result = described_class.new(
        user: user,
        filters: { month: 6, year: 2026 }
      ).call

      expect(result.previous_balance).to eq(700.to_d)
      expect(result.net_balance).to eq(1_350.to_d)
    end

    it "returns nil balances when month or year is missing" do
      user = create(:user)

      result = described_class.new(user: user, filters: { month: nil, year: 2026 }).call

      expect(result.previous_balance).to be_nil
      expect(result.net_balance).to be_nil
    end
  end
end
