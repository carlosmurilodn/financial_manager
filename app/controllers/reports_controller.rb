class ReportsController < ApplicationController
  def index; end

  def forecast
    @start_year = params[:start_year].presence || Date.current.year
    @end_year = params[:end_year].presence || Date.current.year
  end

  def forecast_pdf
    @start_year = params[:start_year].presence || Date.current.year
    @end_year = params[:end_year].presence || Date.current.year

    @forecast_data = {}

    (@start_year.to_i..@end_year.to_i).each do |year|
      @forecast_data[year] = FinancialForecast.for_year(year)
    end

    html = render_to_string(
      template: "reports/forecast_pdf",
      layout: "pdf",
      locals: { start_year: @start_year, end_year: @end_year }
    )

    pdf_options = {
      page_size: "A4",
      print_media_type: true,
      encoding: "UTF-8",
      disable_smart_shrinking: false,
      quiet: true,
      root_url: request.base_url
    }

    pdf = PDFKit.new(html, pdf_options)
    send_data pdf.to_pdf,
              filename: "previsao_financeira_#{@start_year}_#{@end_year}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end
end
