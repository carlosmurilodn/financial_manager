require "spec_helper"
require "date"
require "active_support/core_ext/date/calculations"
require "active_support/core_ext/time/calculations"
require_relative "../../app/services/financial_forecast"

RSpec.describe FinancialForecast do
  describe ".for_year" do
    it "builds a monthly forecast with accumulated balance" do
      stub_const("Income", Class.new do
        def self.where(...); end
      end)
      stub_const("Expense", Class.new do
        def self.where(...); end
        def self.effective_sum(_scope); end
      end)

      monthly_incomes = { 1 => 100, 2 => 200 }
      monthly_expenses = { 1 => 40, 2 => 60 }

      allow(Income).to receive(:where) do |conditions, date = nil|
        if conditions == "balance_month < ?"
          expect(date).to eq(Date.new(2026, 1, 1))
          double("previous_income_scope", sum: 1_000)
        else
          month = conditions.fetch(:balance_month).begin.month
          double("monthly_income_scope", sum: monthly_incomes.fetch(month, 0))
        end
      end

      allow(Expense).to receive(:where) do |conditions, date = nil|
        if conditions == "balance_month < ?"
          expect(date).to eq(Date.new(2026, 1, 1))
          [ :previous_expense_scope ]
        else
          [ :monthly_expense_scope, conditions.fetch(:balance_month).begin.month ]
        end
      end

      allow(Expense).to receive(:effective_sum) do |scope|
        scope.first == :previous_expense_scope ? 300 : monthly_expenses.fetch(scope.last, 0)
      end

      result = described_class.for_year("2026")

      expect(result.keys).to eq((1..12).to_a)
      expect(result[1]).to eq(receitas: 100, despesas: 40, saldo: 760)
      expect(result[2]).to eq(receitas: 200, despesas: 60, saldo: 900)
      expect(result[12]).to eq(receitas: 0, despesas: 0, saldo: 900)
    end
  end
end
