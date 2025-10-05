class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy toggle_paid]

  def index
    # Array que vai conter despesas e parcelas
    @expenses = []

    # Buscar despesas ordenadas por mês do balanço e data
    Expense.order(balance_month: :desc, date: :asc).each do |expense|
      @expenses << expense
      if expense.payment_method_credito_parcelado? && expense.installments.any?
        expense.installments.order(:number).each do |inst|
          @expenses << inst
        end
      end
    end

    filter_by_month
    calculate_totals
  end

  def show; end

  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.amount = normalize_amount(params[:expense][:amount])

    # Sempre pai se for parcelado
    @expense.is_parent = true if @expense.payment_method_credito_parcelado?

    if @expense.save
      redirect_to expenses_path, notice: "Despesa criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit; end

  def update
    @expense.amount = normalize_amount(params[:expense][:amount])

    if @expense.update(expense_params.except(:amount))
      # Regenerar parcelas futuras caso parcela atual ou total mudem
      if @expense.payment_method_credito_parcelado? && @expense.is_parent
        @expense.installments.where("number > ?", @expense.current_installment).destroy_all
        @expense.generate_future_installments
      end
      redirect_to expenses_path, notice: "Despesa atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy

    # Recarrega @expenses para recalcular totais
    @expenses = []
    Expense.order(balance_month: :desc, date: :asc).each do |expense|
      if expense.payment_method_credito_parcelado? && expense.is_parent
        @expenses << expense
        expense.installments.order(:number).each { |inst| @expenses << inst }
      else
        @expenses << expense
      end
    end

    calculate_totals

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expenses_path, notice: "Despesa removida com sucesso!" }
    end
  end


  def toggle_paid
    @expense.update(paid: !@expense.paid)

    # Reconstrói @expenses para recalcular os totais
    @expenses = []

    Expense.order(balance_month: :desc, date: :asc).each do |expense|
      if expense.payment_method_credito_parcelado? && expense.is_parent
        @expenses << expense
        expense.installments.order(:number).each { |inst| @expenses << inst }
      else
        @expenses << expense
      end
    end

    # Aplica filtro de mês se houver
    filter_by_month

    # Calcula os totais
    calculate_totals

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expenses_path }
    end
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(
      :amount, :description, :date, :balance_month,
      :category_id, :payment_method, :card_id, :paid,
      :installments_count, :current_installment, :is_parent
    )
  end

  def normalize_amount(amount_param)
    return 0 if amount_param.blank?
    cleaned = amount_param.to_s.gsub(/[^\d,\.]/, '')
    cleaned.tr!(',', '.') if cleaned.count(',') == 1 && cleaned.count('.') <= 1
    cleaned.gsub!('.', '') if cleaned.count('.') > 1
    cleaned.to_d
  end

  # ----------------------
  # Totais
  # ----------------------
  def calculate_totals
    @total_amount   = @expenses.sum { |e| e.amount }
    @total_paid     = @expenses.select { |e| e.paid? }.sum { |e| e.amount }
    @total_unpaid   = @expenses.select { |e| !e.paid? }.sum { |e| e.amount }
  end

  # ----------------------
  # Filtro por mês
  # ----------------------
  def filter_by_month
    return unless params[:month].present?

    begin
      date = Date.parse(params[:month] + "-01")

      @expenses.select! do |e|
        month = e.is_a?(Installment) ? e.due_date : e.balance_month
        (month.beginning_of_month..month.end_of_month).cover?(date)
      end
    rescue ArgumentError
      flash.now[:alert] = "Data inválida"
    end
  end
end
