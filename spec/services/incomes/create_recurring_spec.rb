require "spec_helper"
require "date"
require "active_support/core_ext/integer/time"
require_relative "../../../app/services/incomes/create_recurring"

RSpec.describe Incomes::CreateRecurring do
  describe ".call" do
    it "creates one future income for each repetition" do
      incomes = double("incomes")
      user = double("user", incomes: incomes)
      income = double(
        "income",
        description: "Salario",
        amount: 3_000,
        date: Date.new(2026, 6, 10),
        balance_month: Date.new(2026, 6, 1),
        category_id: 42,
        repetir: 2
      )

      expect(incomes).to receive(:create!).with(
        description: "Salario",
        amount: 3_000,
        date: Date.new(2026, 7, 10),
        balance_month: Date.new(2026, 7, 1),
        paid: false,
        category_id: 42
      ).ordered

      expect(incomes).to receive(:create!).with(
        description: "Salario",
        amount: 3_000,
        date: Date.new(2026, 8, 10),
        balance_month: Date.new(2026, 8, 1),
        paid: false,
        category_id: 42
      ).ordered

      described_class.call(income: income, user: user)
    end

    it "does not create future incomes when repetitions are zero" do
      incomes = double("incomes")
      user = double("user", incomes: incomes)
      income = double("income", repetir: 0)

      expect(incomes).not_to receive(:create!)

      described_class.call(income: income, user: user)
    end

    it "does not create future incomes when repetitions are negative" do
      incomes = double("incomes")
      user = double("user", incomes: incomes)
      income = double("income", repetir: -3)

      expect(incomes).not_to receive(:create!)

      described_class.call(income: income, user: user)
    end
  end
end
