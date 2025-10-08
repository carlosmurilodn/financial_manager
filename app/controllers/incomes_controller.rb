class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    @month = params[:month].present? ? params[:month].to_i : Date.today.month
    @year  = params[:year].present? ? params[:year].to_i : Date.today.year
    @description_filter = params[:description].to_s.strip if params[:description].present?
    @paid_filter = params.key?(:paid) ? params[:paid] : nil
    @received_filter = params.key?(:received) ? params[:received] : nil

    begin
      date = Date.new(@year, @month, 1)
      @incomes = Income.where(balance_month: date.beginning_of_month..date.end_of_month)
                       .order(date: :asc)
    rescue ArgumentError
      flash.now[:alert] = "Mês ou ano inválido"
      @incomes = Income.none
    end

    # Aplicando filtros
    @incomes = @incomes.where("description ILIKE ?", "%#{@description_filter}%") if @description_filter.present?

    if @paid_filter.present?
      paid_value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
      @incomes = @incomes.where(paid: paid_value)
    end

    if @received_filter.present?
      received_value = ActiveModel::Type::Boolean.new.cast(@received_filter)
      @incomes = @incomes.where(received: received_value)
    end

    # ------------------------------
    # Totais do mês atual
    # ------------------------------
    @total_amount   = @incomes.sum(:amount)
    @total_received = @incomes.where(paid: true).sum(:amount)
    @total_pending  = @incomes.where(paid: false).sum(:amount)

    # ------------------------------
    # Saldo acumulado até o mês anterior
    # ------------------------------
    @previous_balance = accumulated_balance_before(date)

    # ------------------------------
    # Total geral incluindo saldo anterior
    # ------------------------------
    @total_with_previous_balance = @total_amount + @previous_balance
  end

  def show; end

  def new
    @income = Income.new
  end

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

  def toggle_paid
    @income.update(paid: !@income.paid)
    redirect_to incomes_path
  end

  private

  def set_income
    @income = Income.find(params[:id])
  end

  def income_params
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid, :received)
    permitted[:amount] = parse_brazilian_currency(permitted[:amount])
    permitted
  end

  def parse_brazilian_currency(value)
    return nil if value.blank?
    value.to_s.gsub(/[^\d,]/, "").gsub(".", "").tr(",", ".").to_f
  end

  def accumulated_balance_before(date)
    balance = 0
    first_income_date = Income.minimum(:balance_month) || Date.today
    first_expense_date = Expense.minimum(:balance_month) || Date.today
    first_date = [first_income_date, first_expense_date].min.beginning_of_month

    current_month = first_date
    while current_month < date.beginning_of_month
      incomes_total = Income.where(balance_month: current_month..current_month.end_of_month, paid: true).sum(:amount)
      expenses_total = Expense.where(balance_month: current_month..current_month.end_of_month).sum do |e|
        if e.payment_method_credito_parcelado? && e.installments.any?
          e.installments.select(&:paid).sum(&:amount)
        else
          e.paid? ? e.amount : 0
        end
      end
      balance += incomes_total - expenses_total
      current_month = current_month.next_month
    end

    balance
  end
end
