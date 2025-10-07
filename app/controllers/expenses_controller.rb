class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy toggle_paid]

  def index
    # Carrega despesas e aplica filtros
    load_expenses
  end

  def show; end

  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.amount = normalize_amount(params[:expense][:amount])
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
      # Regenerar parcelas futuras se for pai parcelado
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
    load_expenses

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expenses_path, notice: "Despesa removida com sucesso!" }
    end
  end

  def toggle_paid
    @expense.update(paid: !@expense.paid)

    # Recarrega despesas e recalcula totais antes de renderizar
    load_expenses

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "expense_#{@expense.id}",
            partial: "expense_row",
            locals: { expense: @expense }
          ),
          turbo_stream.replace(
            "expenses-totals",
            partial: "expenses_totals"
          )
        ]
      end
      format.html { redirect_to expenses_path }
    end
  end

  private

  # --------------------------
  # Utilitários
  # --------------------------
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

  # --------------------------
  # Carrega despesas e aplica filtros
  # --------------------------
  def load_expenses
    # Define mês/ano padrão
    params[:month] ||= Date.today.month
    params[:year]  ||= Date.today.year

    # Monta lista de despesas e parcelas
    @expenses = []
    Expense.order(balance_month: :desc, date: :asc).each do |expense|
      @expenses << expense
      if expense.payment_method_credito_parcelado? && expense.installments.any?
        expense.installments.order(:number).each { |inst| @expenses << inst }
      end
    end

    # Aplica filtros
    filter_by_month
    filter_by_category
    filter_by_payment_method
    filter_by_card
    filter_by_paid

    # Calcula totais e saldo líquido
    calculate_totals
    calculate_net_balance
  end

  # --------------------------
  # Totais e Saldo
  # --------------------------
  def calculate_totals
    @total_amount = @expenses.sum(&:amount)
    @total_paid   = @expenses.select(&:paid?).sum(&:amount)
    @total_unpaid = @expenses.reject(&:paid?).sum(&:amount)
  end

  def calculate_net_balance
    month = params[:month].to_i
    year  = params[:year].to_i
    return unless month.positive? && year.positive?

    month_start = Date.new(year, month, 1)
    month_range = month_start.all_month

    total_received_incomes = Income.where(paid: true, balance_month: month_range).sum(:amount)
    @net_balance = total_received_incomes - (@total_paid || 0)
  end

  # --------------------------
  # Filtros
  # --------------------------
  def filter_by_month
    return unless params[:month].present? && params[:year].present?

    month = params[:month].to_i
    year  = params[:year].to_i

    @expenses.select! do |e|
      date_to_check = e.respond_to?(:due_date) ? e.due_date : e.balance_month
      date_to_check.month == month && date_to_check.year == year
    end
  end

  def filter_by_category
    return unless params[:category_id].present?
    @expenses.select! { |e| e.category_id.to_s == params[:category_id].to_s }
  end

  def filter_by_payment_method
    return unless params[:payment_method].present?
    @expenses.select! { |e| e.payment_method == params[:payment_method] }
  end

  def filter_by_card
    return unless params[:card_id].present?
    @expenses.select! { |e| e.card_id.to_s == params[:card_id].to_s }
  end

  def filter_by_paid
    return if params[:paid].blank?
    value = ActiveModel::Type::Boolean.new.cast(params[:paid])
    @expenses.select! { |e| e.paid == value }
  end
end
