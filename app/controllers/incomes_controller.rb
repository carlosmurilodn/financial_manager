class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    # ==============================
    # Persistência de filtros
    # ==============================
    session[:incomes_filters] ||= {}

    session[:incomes_filters][:month]       = params[:month].to_i if params[:month].present?
    session[:incomes_filters][:year]        = params[:year].to_i  if params[:year].present?
    session[:incomes_filters][:description] = params[:description].to_s.strip if params[:description].present?
    session[:incomes_filters][:paid]        = params[:paid] if params.key?(:paid)

    @month = session[:incomes_filters][:month].presence
    @year  = session[:incomes_filters][:year].presence
    @description_filter = session[:incomes_filters][:description]
    @paid_filter = session[:incomes_filters][:paid].presence

    # ==============================
    # Montagem do filtro de data
    # ==============================
    if @month.present? && @year.present? && @month.to_i > 0 && @year.to_i > 0
      @filter_date = Date.new(@year.to_i, @month.to_i, 1) rescue Date.today
      @incomes = Income.where(balance_month: @filter_date.beginning_of_month..@filter_date.end_of_month)
    else
      @filter_date = nil
      @incomes = Income.all
    end

    # ==============================
    # Aplicar demais filtros
    # ==============================
    @incomes = @incomes.where("description ILIKE ?", "%#{@description_filter}%") if @description_filter.present?

    if @paid_filter.present?
      paid_value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
      @incomes = @incomes.where(paid: paid_value)
    end

    @incomes = @incomes.order(:date)

    # ==============================
    # Totais e saldos
    # ==============================
    if @filter_date
      @previous_balance = calculate_previous_balance(@filter_date)
      @total_received   = Income.where("balance_month <= ? AND paid = true", @filter_date.end_of_month).sum(:amount)
      current_month_range = @filter_date.beginning_of_month..@filter_date.end_of_month
      @total_pending    = Income.where(balance_month: current_month_range, paid: false).sum(:amount)
      @current_balance  = @total_received - total_expenses_until(@filter_date)
    else
      @previous_balance = 0
      @total_received   = @incomes.where(paid: true).sum(:amount)
      @total_pending    = @incomes.where(paid: false).sum(:amount)
      @current_balance  = @total_received - total_expenses_until(Date.today)
    end
  end

  def show; end
  def new; @income = Income.new; end

  def create
    @income = Income.new(income_params)
    if @income.save
      redirect_to incomes_path, notice: "Receita criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @income.update(income_params)
      redirect_to incomes_path, notice: "Receita atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @income.destroy
    redirect_to incomes_path, notice: "Receita removida com sucesso!"
  end

  def clear_filters
    session.delete(:incomes_filters)
    redirect_to incomes_path, notice: "Filtros limpos com sucesso."
  end

  def toggle_paid
    @income.update(paid: !@income.paid)
    redirect_to incomes_path
  end

  private

  def set_income
    @income = Income.find(params[:id])
  end

  def income_params
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid)
    permitted[:amount] = parse_brazilian_currency(permitted[:amount])
    permitted
  end

  def parse_brazilian_currency(value)
    return nil if value.blank?
    value.to_s.gsub(/[^\d,]/, "").gsub(".", "").tr(",", ".").to_f
  end

  # ==============================
  # Saldo do mês anterior
  # ==============================
  def calculate_previous_balance(filter_date)
    previous_incomes = Income.where("balance_month < ? AND paid = true", filter_date.beginning_of_month).sum(:amount)
    previous_expenses = total_expenses_until(filter_date.beginning_of_month - 1.day)
    previous_incomes - previous_expenses
  end

  # ==============================
  # Soma despesas pagas incluindo parcelas
  # ==============================
  def total_expenses_until(date)
    normal_expenses = Expense.where("balance_month <= ? AND paid = true", date).sum(:amount)
    installments_paid = Installment.where("due_date <= ? AND paid = true", date).sum(:amount)
    normal_expenses + installments_paid
  end
end
