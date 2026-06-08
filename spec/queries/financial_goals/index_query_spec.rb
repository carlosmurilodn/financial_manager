require "rails_helper"

RSpec.describe FinancialGoals::IndexQuery do
  include ActiveSupport::Testing::TimeHelpers

  describe "#call" do
    around do |example|
      travel_to(Date.new(2026, 6, 7)) { example.run }
    end

    it "filters goals by description, category, status, priority and due date" do
      user = create(:user)
      other_user = create(:user)
      category = create(:category, name: "Reserva")
      other_category = create(:category, name: "Viagem")
      matching_goal = create(
        :financial_goal,
        user: user,
        category: category,
        description: "Reserva principal",
        target_amount: 10_000,
        current_amount: 4_000,
        due_date: Date.new(2026, 12, 31),
        status: :in_progress,
        priority: :high
      )
      create(
        :financial_goal,
        user: user,
        category: other_category,
        description: "Viagem principal",
        due_date: Date.new(2026, 12, 31),
        status: :in_progress,
        priority: :high
      )
      create(
        :financial_goal,
        user: user,
        category: category,
        description: "Reserva futura",
        due_date: Date.new(2027, 1, 1),
        status: :planned,
        priority: :high
      )
      create(
        :financial_goal,
        user: other_user,
        category: category,
        description: "Reserva principal",
        due_date: Date.new(2026, 12, 31),
        status: :in_progress,
        priority: :high
      )

      result = described_class.new(
        user: user,
        filters: {
          description: "reserva",
          category_id: category.id,
          status: "in_progress",
          priority: "high",
          due_until: "31/12/2026"
        }
      ).call

      expect(result.goals).to contain_exactly(matching_goal)
      expect(result.count).to eq(1)
      expect(result.active_count).to eq(1)
      expect(result.target_total).to eq(10_000.to_d)
      expect(result.current_total).to eq(4_000.to_d)
      expect(result.nearest_due_date).to eq(Date.new(2026, 12, 31))
    end

    it "filters goals by progress and monetary ranges using included resources" do
      user = create(:user)
      card = create(:card, user: user, total_limit: 5_000)
      create(:expense, :card_payment, user: user, card: card, amount: 1_000, paid: false)
      matching_goal = create(
        :financial_goal,
        user: user,
        target_amount: 10_000,
        current_amount: 0,
        due_date: Date.new(2026, 12, 31)
      )
      create(:financial_goal_resource, financial_goal: matching_goal, amount: 4_000)
      create(:financial_goal_resource, :credit_limit, financial_goal: matching_goal, source: card)

      create(
        :financial_goal,
        user: user,
        target_amount: 10_000,
        current_amount: 1_000,
        due_date: Date.new(2026, 12, 31)
      )

      result = described_class.new(
        user: user,
        filters: {
          progress_min: "40",
          current_amount_min: "R$ 4.000,00",
          target_amount_min: "R$ 10.000,00",
          credit_amount_min: "R$ 4.000,00",
          potential_amount_min: "R$ 8.000,00",
          remaining_amount_max: "R$ 6.000,00",
          monthly_amount_max: "R$ 1.000,00"
        }
      ).call

      expect(result.goals).to contain_exactly(matching_goal)
      expect(result.current_total).to eq(4_000.to_d)
    end

    it "ignores completed goals when calculating nearest due date" do
      user = create(:user)
      create(:financial_goal, user: user, status: :completed, due_date: Date.new(2026, 7, 1))
      active_goal = create(:financial_goal, user: user, status: :planned, due_date: Date.new(2026, 8, 1))

      result = described_class.new(user: user, filters: {}).call

      expect(result.nearest_due_date).to eq(active_goal.due_date)
    end
  end
end
