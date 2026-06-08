module Reports
  class ForecastQuery
    Result = Struct.new(
      :start_year,
      :end_year,
      :forecast_data,
      :filename,
      keyword_init: true
    )

    def initialize(start_year:, end_year:)
      @start_year = start_year.presence || Date.current.year
      @end_year = end_year.presence || Date.current.year
    end

    def call
      Result.new(
        start_year: start_year,
        end_year: end_year,
        forecast_data: forecast_data,
        filename: "previsao_financeira_#{start_year}_#{end_year}.pdf"
      )
    end

    private

    attr_reader :start_year, :end_year

    def forecast_data
      (start_year.to_i..end_year.to_i).each_with_object({}) do |year, data|
        data[year] = FinancialForecast.for_year(year)
      end
    end
  end
end
