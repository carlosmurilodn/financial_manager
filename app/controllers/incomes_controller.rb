class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  # Chaves de filtro para simplificar a manipulação da sessão
  FILTER_KEYS = %i[month year description paid].freeze

  def index
    load_filters
    apply_filters
    calculate_all_totals
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

  # -------------------------- Configuração e Parâmetros --------------------------

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

  # -------------------------- Filtros --------------------------

  # Carrega filtros da sessão/params e define variáveis de instância
  def load_filters
    session[:incomes_filters] ||= {}

    FILTER_KEYS.each do |key|
      # Atualiza a sessão apenas se o parâmetro estiver presente
      session[:incomes_filters][key] = params[key] if params.key?(key)

      # Define a variável de instância com o valor da sessão
      value = session[:incomes_filters][key].presence
      instance_variable_set("@#{key}_filter", value)
    end

    @month = @month_filter
    @year = @year_filter
    @description_filter = @description_filter&.strip # Garante a remoção de espaços
    @paid_filter = @paid_filter.presence
  end

  # Aplica todos os filtros e define @incomes e @filter_date
  def apply_filters
    @incomes = Income.all
    @filter_date = nil

    # Filtro principal de data (mês/ano)
    if @month.to_i > 0 && @year.to_i > 0
      @filter_date = Date.new(@year.to_i, @month.to_i, 1) rescue Date.today
      range = @filter_date.all_month # all_month é mais conciso
      @incomes = @incomes.where(balance_month: range)
    end

    # Filtro de descrição
    if @description_filter.present?
      @incomes = @incomes.where("description ILIKE ?", "%#{@description_filter}%")
    end

    # Filtro de pago
    if @paid_filter.present?
      paid_value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
      @incomes = @incomes.where(paid: paid_value)
    end

    @incomes = @incomes.order(:date)
  end

  # -------------------------- Totais e Saldos --------------------------

  def calculate_all_totals
    if @filter_date
      end_of_month = @filter_date.end_of_month

      # Totais do mês filtrado
      @total_received = @incomes.where(paid: true).sum(:amount) # Já filtrado por data
      @total_pending = @incomes.where(paid: false).sum(:amount) # Já filtrado por data

      # Saldo acumulado
      total_incomes_acc = Income.where("balance_month <= ? AND paid = true", end_of_month).sum(:amount)
      total_expenses_acc = total_expenses_until(end_of_month)

      @current_balance = total_incomes_acc - total_expenses_acc
      @previous_balance = calculate_previous_balance(@filter_date)

    else
      # Se não houver filtro de data, usa o conjunto completo
      @total_received = @incomes.where(paid: true).sum(:amount)
      @total_pending = @incomes.where(paid: false).sum(:amount)
      @previous_balance = 0
      @current_balance = @total_received - total_expenses_until(Date.today)
    end
  end

  # Saldo do mês anterior
  def calculate_previous_balance(filter_date)
    start_of_month = filter_date.beginning_of_month
    
    previous_incomes = Income.where("balance_month < ? AND paid = true", start_of_month).sum(:amount)
    # Total de despesas pagas ATÉ o dia anterior ao início do mês
    previous_expenses = total_expenses_until(start_of_month - 1.day)
    
    previous_incomes - previous_expenses
  end

  # Soma despesas pagas (normais + parcelas) até uma data
  def total_expenses_until(date)
    normal_expenses = Expense.where("balance_month <= ? AND paid = true", date).sum(:amount)
    installments_paid = Installment.where("due_date <= ? AND paid = true", date).sum(:amount)
    normal_expenses + installments_paid
  end
end