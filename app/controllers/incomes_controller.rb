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

    assign_income_dates

    if @income.save
      create_recurring_incomes(@income)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "modal",
            "<turbo-stream action='visit' target='_top' url='#{incomes_path}'></turbo-stream>".html_safe
          )
        end

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
    assign_income_dates

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
          turbo_stream.replace("incomes-hero-kpis", partial: "hero_kpis")
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
          turbo_stream.replace("incomes-hero-kpis", partial: "hero_kpis")
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
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid, :repetir, :category_id)
    permitted[:amount] = parse_brazilian_amount(permitted[:amount])
    permitted
  end

  def create_recurring_incomes(income)
    repetir = income.repetir.to_i
    return if repetir <= 0

    repetir.times do |i|
      Income.create!(
        description: income.description,
        amount: income.amount,
        date: income.date + (i + 1).month,
        balance_month: income.balance_month + (i + 1).month,
        paid: false,
        category_id: income.category_id
      )
    end
  end

  def load_incomes
    session[:incomes_month] = params[:month].to_i if params[:month].present?
    @month = session[:incomes_month]
    @month = nil if @month.blank? || @month == 0

    session[:incomes_year] = params[:year].to_i if params[:year].present?
    @year = session[:incomes_year]
    @year = nil if @year.blank? || @year == 0

    session[:incomes_description] = params[:description].to_s.strip if params[:description].present?
    @description_filter = session[:incomes_description].presence

    session[:incomes_paid] = params[:paid] if params.key?(:paid)
    @paid_filter = session[:incomes_paid]
    @paid_filter = nil if @paid_filter.blank?

    all_incomes = Income.includes(:category).order(balance_month: :asc, date: :asc)
    all_expenses = Expense.order(balance_month: :asc)

    @incomes = all_incomes.to_a
    filter_by_month
    filter_by_description
    filter_by_paid
    calculate_totals

    if @month && @year
      previous_month_end = Date.new(@year, @month, 1) - 1.day

      receitas_anteriores = all_incomes.where("balance_month <= ?", previous_month_end).sum(:amount)
      despesas_anteriores = all_expenses.where("balance_month <= ?", previous_month_end).sum(:amount)

      @previous_balance = receitas_anteriores - despesas_anteriores

      current_month_end = Date.new(@year, @month, 1).end_of_month
      receitas_ate_mes = all_incomes.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)
      despesas_ate_mes = all_expenses.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)

      @current_balance = receitas_ate_mes - despesas_ate_mes
    else
      @previous_balance = 0
      @current_balance = 0
    end
  end

  def assign_income_dates
    @income.date = parse_brazilian_date(income_params[:date])
    @income.balance_month = parse_brazilian_date(income_params[:balance_month])
  end

  def filter_by_month
    return if @month.nil? || @year.nil?

    @incomes.select! { |income| income.balance_month.month == @month && income.balance_month.year == @year }
  end

  def filter_by_description
    return if @description_filter.blank?

    @incomes.select! { |income| income.description.to_s.downcase.include?(@description_filter.downcase) }
  end

  def filter_by_paid
    return if @paid_filter.nil?

    value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
    @incomes.select! { |income| income.paid == value }
  end

  def calculate_totals
    @total_amount = @incomes.sum(&:amount)
    @total_received = @incomes.select(&:paid?).sum(&:amount)
    @total_pending = @incomes.reject(&:paid?).sum(&:amount)
  end
end
