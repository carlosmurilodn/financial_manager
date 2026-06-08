require "rails_helper"

RSpec.describe Incomes::IndexQuery do
  describe "#call" do
    it "filters incomes by month, description and paid status" do
      user = create(:user)
      other_user = create(:user)

      matching_income = create(
        :income,
        user: user,
        description: "Salario mensal",
        amount: 3_000,
        balance_month: Date.new(2026, 6, 1),
        paid: true
      )
      create(
        :income,
        user: user,
        description: "Bonus mensal",
        amount: 700,
        balance_month: Date.new(2026, 6, 1),
        paid: false
      )
      create(
        :income,
        user: user,
        description: "Salario futuro",
        amount: 3_100,
        balance_month: Date.new(2026, 7, 1),
        paid: true
      )
      create(
        :income,
        user: other_user,
        description: "Salario mensal",
        amount: 9_000,
        balance_month: Date.new(2026, 6, 1),
        paid: true
      )

      result = described_class.new(
        user: user,
        filters: {
          month: 6,
          year: 2026,
          description: "salario",
          paid: "true"
        }
      ).call

      expect(result.incomes).to contain_exactly(matching_income)
      expect(result.total_amount).to eq(3_000.to_d)
      expect(result.total_received).to eq(3_000.to_d)
      expect(result.total_pending).to eq(0.to_d)
    end

    it "calculates previous and current balances for the selected period" do
      user = create(:user)

      create(:income, user: user, amount: 1_000, balance_month: Date.new(2026, 5, 1), paid: true)
      create(:expense, user: user, amount: 300, balance_month: Date.new(2026, 5, 1), paid: false)
      create(:income, user: user, amount: 500, balance_month: Date.new(2026, 6, 1), paid: true)
      create(:income, user: user, amount: 200, balance_month: Date.new(2026, 6, 1), paid: false)
      create(:expense, :paid, user: user, amount: 150, balance_month: Date.new(2026, 6, 1))
      create(:expense, user: user, amount: 80, balance_month: Date.new(2026, 6, 1), paid: false)

      result = described_class.new(
        user: user,
        filters: { month: 6, year: 2026, description: nil, paid: nil }
      ).call

      expect(result.previous_balance).to eq(700.to_d)
      expect(result.current_balance).to eq(1_350.to_d)
    end

    it "returns zero balances when month or year is missing" do
      user = create(:user)
      create(:income, user: user, amount: 1_000, balance_month: Date.new(2026, 5, 1))

      result = described_class.new(
        user: user,
        filters: { month: nil, year: 2026, description: nil, paid: nil }
      ).call

      expect(result.previous_balance).to eq(0)
      expect(result.current_balance).to eq(0)
    end
  end
end
