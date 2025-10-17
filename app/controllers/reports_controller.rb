class ReportsController < ApplicationController
  def index; end

  def forecast
    @start_year = params[:start_year].presence || Date.current.year
    @end_year   = params[:end_year].presence   || Date.current.year
  end

  def forecast_pdf
    @start_year = params[:start_year].presence || Date.current.year
    @end_year   = params[:end_year].presence   || Date.current.year

    @forecast_data = {}

    (@start_year.to_i..@end_year.to_i).each do |year|
      @forecast_data[year] = {}

      total_receitas_anteriores = Income.where("balance_month < ?", Date.new(year, 1, 1)).sum(:amount)
      total_despesas_anteriores = Expense.where("balance_month < ?", Date.new(year, 1, 1)).sum(:amount) +
                                  Installment.where("balance_month < ?", Date.new(year, 1, 1)).sum(:amount)

      (1..12).each do |month|
        month_range = Date.new(year, month, 1).all_month

        receitas_mes = Income.where(balance_month: month_range).sum(:amount)
        despesas_mes = Expense.where(balance_month: month_range).sum(:amount) +
                        Installment.where(balance_month: month_range).sum(:amount)

        saldo_anteriores = total_receitas_anteriores - total_despesas_anteriores
        total_receitas   = saldo_anteriores + receitas_mes
        saldo_liquido    = total_receitas - despesas_mes

        @forecast_data[year][month] = {
          receitas: total_receitas,
          despesas: despesas_mes,
          saldo: saldo_liquido
        }

        # Atualiza acumulados para o próximo mês
        total_receitas_anteriores += receitas_mes
        total_despesas_anteriores += despesas_mes
      end
    end

    # Renderiza HTML para string usando a view PDF
    html = render_to_string(
      template: "reports/forecast_pdf",
      layout: "pdf",
      locals: { start_year: @start_year, end_year: @end_year }
    )

    # Opções PDFKit
    pdf_options = {
      page_size: "A4",
      print_media_type: true,
      encoding: "UTF-8",
      disable_smart_shrinking: false,
      quiet: true,
      root_url: request.base_url
    }

    # Gera e envia PDF
    pdf = PDFKit.new(html, pdf_options)
    send_data pdf.to_pdf,
              filename: "previsao_financeira_#{@start_year}_#{@end_year}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end
end
