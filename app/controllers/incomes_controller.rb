class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    load_incomes
  end

  def show; end
  def new; @income = Income.new; end

  def create
    @income = Income.new(income_params)
    @income.repetir ||= 0

    # Converter datas
    @income.date = Date.strptime(income_params[:date], "%d/%m/%Y") rescue nil
    @income.balance_month = Date.strptime(income_params[:balance_month], "%d/%m/%Y") rescue nil

    if @income.save
      gerar_repeticoes(@income)

      respond_to do |format|
        # Turbo: fecha o modal e recarrega a página inteira
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "modal",
            "<turbo-stream action='visit' target='_top' url='#{incomes_path}'></turbo-stream>".html_safe
          )
        end

        # Fallback HTML
        format.html { redirect_to incomes_path, notice: "Receita criada com sucesso!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    @income.date = Date.strptime(income_params[:date], "%d/%m/%Y") rescue nil
    @income.balance_month = Date.strptime(income_params[:balance_month], "%d/%m/%Y") rescue nil

    if @income.update(income_params.except(:date, :balance_month))
      redirect_to incomes_path, notice: "Receita atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @income.destroy
    load_incomes

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("income_#{@income.id}"),
          turbo_stream.replace("incomes-totals", partial: "incomes_totals", locals: {
            total_received: @total_received,
            total_pending: @total_pending,
            total_amount: @total_amount
          })
        ]
      end
      format.html { redirect_to incomes_path, notice: "Receita removida com sucesso!" }
    end
  end

  def toggle_paid
    @income.update(paid: !@income.paid)
    load_incomes

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("income_#{@income.id}", partial: "income_row", locals: { income: @income }),
          turbo_stream.replace("incomes-totals", partial: "incomes_totals", locals: {
            total_received: @total_received,
            total_pending: @total_pending,
            total_amount: @total_amount
          })
        ]
      end
      format.html { redirect_to incomes_path }
    end
  end

  def clear_filters
    session.delete(:incomes_month)
    session.delete(:incomes_year)
    session.delete(:incomes_description)
    session.delete(:incomes_paid)
    redirect_to incomes_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def set_income
    @income = Income.find(params[:id])
  end

  def income_params
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid, :repetir)
    permitted[:amount] = parse_brazilian_currency(permitted[:amount])
    permitted
  end

  def parse_brazilian_currency(value)
    return nil if value.blank?
    value.to_s.gsub(/[^\d,]/, "").gsub(".", "").tr(",", ".").to_f
  end

  # --------------------------
  # Repetições
  # --------------------------
  def gerar_repeticoes(income)
    repetir = income.repetir.to_i
    return if repetir <= 0

    repetir.times do |i|
      Income.create!(
        description: income.description,
        amount: income.amount,
        date: income.date + (i + 1).month,
        balance_month: income.balance_month + (i + 1).month,
        paid: false
      )
    end
  end

def load_incomes
  # --------------------------
  # Mês e Ano
  # --------------------------
  session[:incomes_month] = params[:month].to_i if params[:month].present?
  @month = session[:incomes_month]
  @month = nil if @month.blank? || @month == 0   # "Todos"

  session[:incomes_year] = params[:year].to_i if params[:year].present?
  @year = session[:incomes_year]
  @year = nil if @year.blank? || @year == 0      # "Todos"

  # --------------------------
  # Descrição e Pago
  # --------------------------
  session[:incomes_description] = params[:description].to_s.strip if params[:description].present?
  @description_filter = session[:incomes_description].presence

  session[:incomes_paid] = params[:paid] if params.key?(:paid)
  @paid_filter = session[:incomes_paid]
  @paid_filter = nil if @paid_filter.blank?

  # --------------------------
  # Carregar receitas e despesas
  # --------------------------
  all_incomes = Income.order(balance_month: :asc, date: :asc)
  all_expenses = Expense.order(balance_month: :asc)
  all_installments = Installment.order(balance_month: :asc)

  # --------------------------
  # Filtro por mês/ano (para view principal)
  # --------------------------
  @incomes = all_incomes.to_a
  filter_by_month
  filter_by_description
  filter_by_paid

  # --------------------------
  # Totais
  # --------------------------
  calculate_totals

  # --------------------------
  # Saldo acumulado
  # --------------------------
  if @month && @year
    # Mês anterior
    previous_month_end = Date.new(@year, @month, 1) - 1.day

    receitas_anteriores = all_incomes.where("balance_month <= ?", previous_month_end).sum(:amount)
    despesas_anteriores = all_expenses.where("balance_month <= ?", previous_month_end).sum(:amount) +
                          all_installments.where("balance_month <= ?", previous_month_end).sum(:amount)

    @previous_balance = receitas_anteriores - despesas_anteriores

    # Mês atual (até o final do mês)
    current_month_end = Date.new(@year, @month, -1)
    receitas_ate_mes = all_incomes.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)
    despesas_ate_mes = all_expenses.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount) +
                       all_installments.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)

    @current_balance = receitas_ate_mes - despesas_ate_mes
  else
    @previous_balance = 0
    @current_balance = 0
  end
end


  # --------------------------
  # Filtros
  # --------------------------
  def filter_by_month
    return if @month.nil? || @year.nil?
    @incomes.select! { |i| i.balance_month.month == @month && i.balance_month.year == @year }
  end

  def filter_by_description
    return if @description_filter.blank?
    @incomes.select! { |i| i.description.to_s.downcase.include?(@description_filter.downcase) }
  end

  def filter_by_paid
    return if @paid_filter.nil?
    value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
    @incomes.select! { |i| i.paid == value }
  end

  # --------------------------
  # Totais
  # --------------------------
  def calculate_totals
    @total_amount   = @incomes.sum(&:amount)
    @total_received = @incomes.select(&:paid?).sum(&:amount)
    @total_pending  = @incomes.reject(&:paid?).sum(&:amount)
  end
end
