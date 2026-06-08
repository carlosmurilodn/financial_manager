require "rails_helper"

RSpec.describe Categories::IndexQuery do
  include ActiveSupport::Testing::TimeHelpers

  describe "#call" do
    around do |example|
      travel_to(Date.new(2026, 6, 7)) { example.run }
    end

    it "returns user categories sorted by normalized name" do
      user = create(:user)
      other_user = create(:user)
      transport = create(:category, name: "Transporte", user_id: user.id)
      food = create(:category, name: "Alimentacao", user_id: user.id)
      create(:category, name: "Outros", user_id: other_user.id)

      result = described_class.new(user: user, description: nil).call

      expect(result.categories).to eq([ food, transport ])
    end

    it "filters categories by normalized description" do
      user = create(:user)
      matching_category = create(:category, name: "Cartao Alimentacao", user_id: user.id)
      create(:category, name: "Transporte", user_id: user.id)

      result = described_class.new(user: user, description: "alimentacao").call

      expect(result.categories).to contain_exactly(matching_category)
    end

    it "calculates current month totals and highlights" do
      user = create(:user)
      food = create(:category, name: "Alimentacao", user_id: user.id)
      transport = create(:category, name: "Transporte", user_id: user.id)

      create(:expense, user: user, category: food, amount: 150, balance_month: Date.new(2026, 6, 1))
      create(:expense, :refund, user: user, category: food, amount: 50, balance_month: Date.new(2026, 6, 1))
      create(:expense, user: user, category: transport, amount: 300, balance_month: Date.new(2026, 6, 1))
      create(:expense, user: user, category: transport, amount: 900, balance_month: Date.new(2026, 5, 1))
      create(:income, user: user, category: food, amount: 1_000, balance_month: Date.new(2026, 6, 1))
      create(:income, user: user, category: nil, amount: 75, balance_month: Date.new(2026, 6, 1))

      result = described_class.new(user: user, description: nil).call

      expect(result.month_expenses).to eq(400.to_d)
      expect(result.month_incomes).to eq(1_075.to_d)
      expect(result.top_expense_value).to eq(300.to_d)
      expect(result.uncategorized_value).to eq(75.to_d)
    end
  end
end
