require "rails_helper"

RSpec.describe Cards::IndexQuery do
  describe "#call" do
    it "calculates card totals and projected available limit for the selected period" do
      user = create(:user)
      other_user = create(:user)
      amazon = create(:card, user: user, name: "Amazon", total_limit: 1_000)
      caixa = create(:card, user: user, name: "Caixa", total_limit: 2_000)

      create(:expense, :card_payment, user: user, card: amazon, amount: 100, balance_month: Date.new(2026, 6, 1), paid: false)
      create(:expense, :card_payment, user: user, card: amazon, amount: 200, balance_month: Date.new(2026, 7, 1), paid: false)
      create(:expense, :card_payment, user: user, card: amazon, amount: 50, balance_month: Date.new(2026, 8, 1), paid: true)
      create(:expense, :card_payment, user: user, card: caixa, amount: 300, balance_month: Date.new(2026, 6, 1), paid: false)
      create(:expense, :card_payment, user: user, card: caixa, amount: 400, balance_month: Date.new(2026, 7, 1), paid: false)
      create(:expense, :card_payment, user: other_user, amount: 9_000, balance_month: Date.new(2026, 6, 1), paid: false)

      result = described_class.new(user: user, description: nil, month: 6, year: 2026).call

      expect(result.cards).to match_array([ amazon, caixa ])
      expect(result.debt_years).to eq([ 2026 ])
      expect(result.debt_totals_by_card).to include(amazon.id => 300.to_d, caixa.id => 700.to_d)
      expect(result.projected_limit_totals_by_card).to include(amazon.id => 200.to_d, caixa.id => 400.to_d)
      expect(result.month_totals_by_card).to include(amazon.id => 100.to_d, caixa.id => 300.to_d)
      expect(result.limit_total).to eq(3_000)
      expect(result.limit_available).to eq(2_400)
      expect(result.limit_used).to eq(600)
      expect(result.open_invoices).to eq(1_000)
    end

    it "filters cards by card name or debt description" do
      user = create(:user)
      amazon = create(:card, user: user, name: "Amazon", total_limit: 1_000)
      caixa = create(:card, user: user, name: "Caixa", total_limit: 1_000)

      create(:expense, :card_payment, user: user, card: amazon, description: "Compra online", amount: 100, balance_month: Date.new(2026, 6, 1), paid: false)
      create(:expense, :card_payment, user: user, card: caixa, description: "Mercado", amount: 200, balance_month: Date.new(2026, 6, 1), paid: false)

      by_card_name = described_class.new(user: user, description: "amazon", month: 6, year: 2026).call
      by_debt_description = described_class.new(user: user, description: "mercado", month: 6, year: 2026).call

      expect(by_card_name.cards).to contain_exactly(amazon)
      expect(by_debt_description.cards).to contain_exactly(caixa)
    end
  end
end
