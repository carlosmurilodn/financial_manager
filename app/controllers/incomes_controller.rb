class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    # ------------------------------
    # Mês, Ano e filtro de descrição
    # ------------------------------
    @month = (params[:month] || Date.today.month).to_i
    @year  = (params[:year] || Date.today.year).to_i
    @description_filter = params[:description].to_s.strip

    begin
      date = Date.new(@year, @month, 1)
      # Filtra receitas do mês selecionado
      @incomes = Income.where(balance_month: date.beginning_of_month..date.end_of_month)
                       .order(date: :asc)
    rescue ArgumentError
      flash.now[:alert] = "Mês ou ano inválido"
      @incomes = Income.none
    end

    # Filtro por descrição
    if @description_filter.present?
      @incomes = @incomes.where("description ILIKE ?", "%#{@description_filter}%")
    end

    # ------------------------------
    # Totais do mês atual
    # ------------------------------
    @total_amount   = @incomes.sum(:amount)
    @total_received = @incomes.where(paid: true).sum(:amount)
    @total_pending  = @incomes.where(paid: false).sum(:amount)

    # ------------------------------
    # Saldo do mês anterior (despesas pagas)
    # ------------------------------
    previous_month_date = date.prev_month
    expenses_last_month = Expense.where(balance_month: previous_month_date.beginning_of_month..previous_month_date.end_of_month)

    @previous_balance = expenses_last_month.sum do |e|
      if e.payment_method_credito_parcelado? && e.installments.any?
        e.installments.select(&:paid).sum(&:amount)
      else
        e.paid? ? e.amount : 0
      end
    end

    # Total geral incluindo saldo anterior
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

  # -------------------------------
  # Strong parameters com normalização
  # -------------------------------
  def income_params
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid)

    # Normaliza o campo amount (ex: "R$ 10.000,00" → 10000.0)
    permitted[:amount] = parse_brazilian_currency(permitted[:amount])

    permitted
  end

  # Converte string de moeda brasileira para decimal
  def parse_brazilian_currency(value)
    return nil if value.blank?

    value.to_s
         .gsub(/[^\d,]/, "") # remove tudo que não for número ou vírgula
         .gsub(".", "")      # remove pontos de milhar
         .gsub(",", ".")     # troca vírgula por ponto decimal
         .to_f
  end
end
