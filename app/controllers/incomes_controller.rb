class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    # ------------------------------
    # Persistência de filtros usando session
    # ------------------------------
    session[:incomes_filters] ||= {}

    # Atualiza session apenas se o parâmetro estiver presente
    session[:incomes_filters][:month] = params[:month].to_i if params[:month].present?
    session[:incomes_filters][:year] = params[:year].to_i if params[:year].present?
    session[:incomes_filters][:description] = params[:description].to_s.strip if params[:description].present?
    session[:incomes_filters][:paid] = params[:paid] if params.key?(:paid)
    session[:incomes_filters][:received] = params[:received] if params.key?(:received)

    # Recupera valores da sessão ou usa padrão (mês/ano atuais)
    @month = session[:incomes_filters][:month]
    @month = nil if @month.blank? || @month == 0

    @year = session[:incomes_filters][:year]
    @year = nil if @year.blank? || @year == 0

    @description_filter = session[:incomes_filters][:description]
    @paid_filter = session[:incomes_filters][:paid]
    @paid_filter = nil if @paid_filter.blank?

    @received_filter = session[:incomes_filters][:received]
    @received_filter = nil if @received_filter.blank?

    # ------------------------------
    # Filtros e carregamento dos dados
    # ------------------------------
    if @month.present? && @year.present?
      begin
        date = Date.new(@year, @month, 1)
        @incomes = Income.where(balance_month: date.beginning_of_month..date.end_of_month)
                         .order(date: :asc)
      rescue ArgumentError
        flash.now[:alert] = "Mês ou ano inválido"
        @incomes = Income.none
      end
    else
      @incomes = Income.all.order(date: :asc)
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
    # Totais
    # ------------------------------
    @total_amount   = @incomes.sum(:amount)
    @total_received = @incomes.where(paid: true).sum(:amount)
    @total_pending  = @incomes.where(paid: false).sum(:amount)

    # ------------------------------
    # Saldo acumulado até o mês anterior
    # ------------------------------
    @previous_balance = accumulated_balance_before(date || Date.today)

    # ------------------------------
    # Total geral incluindo saldo anterior
    # ------------------------------
    @total_with_previous_balance = @total_amount + @previous_balance
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
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid, :received)
    permitted[:amount] = parse_brazilian_currency(permitted[:amount])
    permitted
  end

  def parse_brazilian_currency(value)
    return nil if value.blank?
    value.to_s.gsub(/[^\d,]/, "").gsub(".", "").tr(",", ".").to_f
  end

  # Calcula saldo acumulado até o mês anterior
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
