require "spec_helper"
require "date"
require "active_support/core_ext/date/calculations"
require "active_support/core_ext/object/blank"
require_relative "../../../app/queries/reports/forecast_query"

RSpec.describe Reports::ForecastQuery do
  before do
    stub_const("FinancialForecast", Class.new do
      def self.for_year(_year); end
    end)
  end

  describe "#call" do
    it "builds forecast data for each year in the selected range" do
      allow(FinancialForecast).to receive(:for_year) do |year|
        { 1 => { receitas: year, despesas: 0, saldo: year } }
      end

      result = described_class.new(start_year: "2025", end_year: "2026").call

      expect(result.start_year).to eq("2025")
      expect(result.end_year).to eq("2026")
      expect(result.forecast_data).to eq(
        2025 => { 1 => { receitas: 2025, despesas: 0, saldo: 2025 } },
        2026 => { 1 => { receitas: 2026, despesas: 0, saldo: 2026 } }
      )
      expect(result.filename).to eq("previsao_financeira_2025_2026.pdf")
    end

    it "uses the current year when the range is blank" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 7))
      allow(FinancialForecast).to receive(:for_year).with(2026).and_return({})

      result = described_class.new(start_year: "", end_year: nil).call

      expect(result.start_year).to eq(2026)
      expect(result.end_year).to eq(2026)
      expect(result.forecast_data).to eq(2026 => {})
      expect(result.filename).to eq("previsao_financeira_2026_2026.pdf")
    end
  end
end
