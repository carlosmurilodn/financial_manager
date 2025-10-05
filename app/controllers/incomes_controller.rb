class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    @incomes = Income.order(balance_month: :desc, date: :asc)

    if params[:month].present?
      begin
        date = Date.parse(params[:month] + "-01")
        @incomes = @incomes.where(balance_month: date.beginning_of_month..date.end_of_month)
      rescue ArgumentError
        flash.now[:alert] = "Data inválida"
      end
    end

    @total_amount = @incomes.sum(:amount)
    @total_received = @incomes.where(paid: true).sum(:amount)
    @total_pending = @incomes.where(paid: false).sum(:amount)
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

  # Destroy com suporte a Turbo
  def destroy
    @income.destroy

    # Recarrega as receitas restantes e recalcula os totais
    @incomes = Income.order(balance_month: :desc, date: :asc)
    @total_received = @incomes.where(paid: true).sum(:amount)
    @total_pending = @incomes.where(paid: false).sum(:amount)
    @total_amount = @incomes.sum(:amount)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to incomes_path, notice: "Receita removida com sucesso!" }
    end
  end

  def toggle_paid
    @income.update(paid: !@income.paid)

    @incomes = Income.order(balance_month: :desc, date: :asc)
    @total_received = @incomes.where(paid: true).sum(:amount)
    @total_pending = @incomes.where(paid: false).sum(:amount)
    @total_amount = @incomes.sum(:amount)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to incomes_path }
    end
  end

  private

  def set_income
    @income = Income.find(params[:id])
  end

  def income_params
    params.require(:income).permit(:amount, :description, :date, :balance_month, :paid)
  end
end
