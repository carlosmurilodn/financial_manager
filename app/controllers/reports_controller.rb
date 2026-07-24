class ReportsController < ApplicationController
  def index; end

  def backup
    result = Backups::DatabaseDump.call

    send_data result.data,
              filename: result.filename,
              type: result.content_type,
              disposition: "attachment"
  rescue Backups::DatabaseDump::Error => e
    Rails.logger.error("Manual backup failed: #{e.class} - #{e.message}")
    redirect_to reports_path, alert: "Nao foi possivel gerar o backup: #{e.message}"
  end

  def forecast
    assign_forecast_result(forecast_result)
  end

  def forecast_pdf
    result = forecast_result
    assign_forecast_result(result)

    html = render_to_string(
      template: "reports/forecast_pdf",
      layout: "pdf",
      locals: { start_year: @start_year, end_year: @end_year }
    )

    pdf = PDFKit.new(html, pdf_options)
    send_data pdf.to_pdf,
              filename: result.filename,
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def forecast_result
    Reports::ForecastQuery.new(
      start_year: params[:start_year],
      end_year: params[:end_year]
    ).call
  end

  def assign_forecast_result(result)
    @start_year = result.start_year
    @end_year = result.end_year
    @forecast_data = result.forecast_data
  end

  def pdf_options
    {
      page_size: "A4",
      print_media_type: true,
      encoding: "UTF-8",
      disable_smart_shrinking: false,
      quiet: true,
      root_url: request.base_url
    }
  end
end
