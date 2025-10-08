class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy toggle_paid]

  def index
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
    load_expenses

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("expense_#{@expense.id}", partial: "expense_row", locals: { expense: @expense }),
          turbo_stream.replace("expenses-totals", partial: "expenses_totals")
        ]
      end
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
    cleaned = cleaned.include?(',') ? cleaned.gsub('.', '').tr(',', '.') : cleaned.gsub('.', '')
    BigDecimal(cleaned)
  rescue ArgumentError
    0
  end

  # --------------------------
  # Carrega despesas e aplica filtros via params (sem sessão)
  # --------------------------
  def load_expenses
    @month = params[:month].present? ? params[:month].to_i : Date.today.month
    @year  = params[:year].present? ? params[:year].to_i : Date.today.year
    @category_filter = params[:category_id]
    @payment_method_filter = params[:payment_method]
    @card_filter = params[:card_id]
    @paid_filter = params.key?(:paid) ? params[:paid] : nil

    @expenses = []
    Expense.order(balance_month: :desc, date: :asc).each do |expense|
      @expenses << expense
      if expense.payment_method_credito_parcelado? && expense.installments.any?
        expense.installments.order(:number).each { |inst| @expenses << inst }
      end
    end

    filter_by_month
    filter_by_category
    filter_by_payment_method
    filter_by_card
    filter_by_paid

    calculate_totals
    calculate_net_balance
  end

  # --------------------------
  # Totais
  # --------------------------
  def calculate_totals
    @total_amount = @expenses.sum(&:amount)
    @total_paid   = @expenses.select(&:paid?).sum(&:amount)
    @total_unpaid = @expenses.reject(&:paid?).sum(&:amount)
  end

  def calculate_net_balance
    return unless @month.present? && @year.present?

    month_start = Date.new(@year, @month, 1)
    accumulated_balance = 0
    first_month = Expense.minimum(:balance_month) || Income.minimum(:balance_month) || month_start
    current_month = first_month.beginning_of_month

    while current_month <= month_start
      month_range = current_month.all_month
      incomes_total = Income.where(balance_month: month_range, paid: true).sum(:amount)
      expenses_total = Expense.where(balance_month: month_range).sum do |e|
        if e.payment_method_credito_parcelado? && e.installments.any?
          e.installments.select(&:paid).sum(&:amount)
        else
          e.paid? ? e.amount : 0
        end
      end
      accumulated_balance = accumulated_balance + incomes_total - expenses_total
      current_month = current_month.next_month
    end

    @net_balance = accumulated_balance
    @total_paid   = @expenses.select(&:paid?).sum(&:amount)
    @total_unpaid = @expenses.reject(&:paid?).sum(&:amount)
  end

  # --------------------------
  # Filtros
  # --------------------------
  def filter_by_month
    @expenses.select! do |e|
      date_to_check = e.respond_to?(:due_date) ? e.due_date : e.balance_month
      date_to_check.month == @month && date_to_check.year == @year
    end
  end

  def filter_by_category
    return unless @category_filter.present?
    @expenses.select! { |e| e.category_id.to_s == @category_filter.to_s }
  end

  def filter_by_payment_method
    return unless @payment_method_filter.present?
    @expenses.select! { |e| e.payment_method == @payment_method_filter }
  end

  def filter_by_card
    return unless @card_filter.present?
    @expenses.select! { |e| e.card_id.to_s == @card_filter.to_s }
  end

  def filter_by_paid
    return if @paid_filter.blank?
    value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
    @expenses.select! { |e| e.paid == value }
  end
end
