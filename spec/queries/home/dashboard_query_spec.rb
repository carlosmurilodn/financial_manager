require "rails_helper"

RSpec.describe Home::DashboardQuery do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Date.new(2026, 6, 7)) { example.run }
  end

  describe "#call" do
    it "resolves selected periods and forecast data" do
      allow(FinancialForecast).to receive(:for_year).with(2026).and_return({ junho: "forecast" })

      result = described_class.new(
        params: {
          card_month: "7",
          card_year: "2026",
          category_month: "5",
          category_year: "2026",
          month: "6",
          year: "2026"
        }
      ).call

      expect(result.card_balance_date).to eq(Date.new(2026, 7, 1))
      expect(result.previous_card_balance_date).to eq(Date.new(2026, 6, 1))
      expect(result.next_card_balance_date).to eq(Date.new(2026, 8, 1))
      expect(result.category_expense_date).to eq(Date.new(2026, 5, 1))
      expect(result.calendar_range).to eq(Date.new(2026, 6, 1).all_month)
      expect(result.months).to eq((1..12).to_a)
      expect(result.forecast_data).to eq({ junho: "forecast" })
    end

    it "builds dashboard totals, cards, categories, calendar and financial goals" do
      allow(FinancialForecast).to receive(:for_year).with(2026).and_return({})

      user = create(:user)
      category = create(:category, name: "Alimentacao", color: Category::COLOR_PALETTE.fetch("Azul"))
      card = create(:card, user: user, name: "Amazon", total_limit: 1_000)

      create(:income, user: user, category: category, description: "Salario", amount: 1_000, date: Date.new(2026, 6, 10), balance_month: Date.new(2026, 6, 1), paid: true)
      create(:expense, :paid, user: user, category: category, description: "Mercado", amount: 150, date: Date.new(2026, 6, 11), balance_month: Date.new(2026, 6, 1), payment_method: :pix)
      create(:expense, :card_payment, user: user, category: category, card: card, description: "Compra online", amount: 100, date: Date.new(2026, 6, 12), balance_month: Date.new(2026, 6, 1), paid: false)
      create(:expense, :card_payment, user: user, category: category, card: card, description: "Compra futura", amount: 200, date: Date.new(2026, 7, 12), balance_month: Date.new(2026, 7, 1), paid: false)

      create(:financial_goal, user: user, category: category, description: "Reserva", target_amount: 1_000, current_amount: 500, due_date: Date.new(2026, 9, 1), priority: :high)
      create(:financial_goal, user: user, category: category, description: "Viagem", target_amount: 2_000, current_amount: 0, due_date: Date.new(2026, 12, 1), priority: :medium)

      result = described_class.new(params: { card_month: "6", card_year: "2026", category_month: "6", category_year: "2026", month: "6", year: "2026" }).call
      card_info = result.cards_info.first
      category_summary = result.category_expense_summaries.first

      expect(result.current_balance).to eq(850)
      expect(result.monthly_incomes).to eq(1_000)
      expect(result.monthly_expenses).to eq(250)
      expect(result.net_balance).to eq(550)

      expect(card_info[:card]).to eq(card)
      expect(card_info[:total]).to eq(300)
      expect(card_info[:remaining_limit]).to eq(700)
      expect(card_info[:month_total]).to eq(100)
      expect(card_info[:month_paid]).to be(false)
      expect(card_info[:items]).to contain_exactly(hash_including(description: "Compra online", amount: 100.to_d, paid: false))

      expect(category_summary).to include(name: "Alimentacao", total: 250.0, count: 2, percent: 100.0)
      expect(category_summary[:items]).to contain_exactly(
        hash_including(description: "Mercado", amount: 150.to_d),
        hash_including(description: "Compra online", amount: 100.to_d)
      )

      expect(result.daily_calendar_items[Date.new(2026, 6, 10)][:incomes]).to contain_exactly(hash_including(description: "Alimentacao - Salario", amount: 1_000.to_d))
      expect(result.daily_calendar_items[Date.new(2026, 6, 11)][:expenses]).to contain_exactly(hash_including(description: "Alimentacao - Mercado", amount: 150.to_d))
      expect(result.monthly_agenda_items.map { |item| item.slice(:type, :description) }).to include(
        { type: :income, description: "Alimentacao - Salario" },
        { type: :expense, description: "Alimentacao - Mercado" }
      )

      expect(result.financial_goals_summary.map(&:description)).to eq([ "Reserva", "Viagem" ])
      expect(result.financial_goals_total_remaining).to eq(2_500)
      expect(result.financial_goals_average_progress).to eq(25)
    end
  end
end
