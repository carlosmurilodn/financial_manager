class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy toggle_paid]

  def index
    load_expenses
  end

  def report
    load_expenses
  end

  def show; end
  def new; @expense = Expense.new; end

  def create
    @expense = Expense.new(expense_params)
    @expense.amount = parse_brazilian_amount(params[:expense][:amount], blank: 0)
    @expense.repetir ||= 0

    assign_expense_dates

    if @expense.save
      create_recurring_expenses(@expense)

      respond_to do |format|
        format.html { redirect_to expenses_path, notice: "Despesa criada com sucesso!" }
        format.turbo_stream { render turbo_stream: "" }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    @expense.amount = parse_brazilian_amount(params[:expense][:amount], blank: 0)
    assign_expense_dates

    if @expense.update(expense_params.except(:amount))
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("modal", "")
        end

        format.html do
          redirect_to expenses_path, notice: "Despesa atualizada com sucesso!"
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
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

  def clear_filters
    session.delete(:expenses_month)
    session.delete(:expenses_year)
    session.delete(:expenses_description)
    session.delete(:expenses_category_id)
    session.delete(:expenses_payment_method)
    session.delete(:expenses_card_id)
    session.delete(:expenses_paid)
    redirect_to expenses_path, notice: "Filtros limpos com sucesso!"
  end

  def report_pdf
    load_expenses

    html = render_to_string(
      template: "expenses/report_pdf",
      layout: "pdf"
    )

    pdf_options = {
      page_size: "A4",
      orientation: "Landscape",
      print_media_type: true,
      encoding: "UTF-8",
      disable_smart_shrinking: false,
      quiet: true,
      root_url: request.base_url
    }

    pdf = PDFKit.new(html, pdf_options)

    send_data pdf.to_pdf,
              filename: "relatorio_despesas_#{Date.today.strftime("%d_%m_%Y")}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(
      :amount, :description, :date, :balance_month,
      :category_id, :payment_method, :card_id, :paid,
      :installments_count, :current_installment, :repetir
    )
  end

  def assign_expense_dates
    @expense.date = parse_brazilian_date(expense_params[:date])
    @expense.balance_month = parse_brazilian_date(expense_params[:balance_month])
  end

  def load_expenses
    session[:expenses_month] = params[:month].to_i if params[:month].present?
    @month = session[:expenses_month]
    @month = nil if @month.blank? || @month == 0

    session[:expenses_year] = params[:year].to_i if params[:year].present?
    @year = session[:expenses_year]
    @year = nil if @year.blank? || @year == 0

    session[:expenses_description] = params[:description]&.strip
    @description_filter = session[:expenses_description].presence

    session[:expenses_category_id] = params[:category_id] if params[:category_id].present?
    @category_filter = session[:expenses_category_id]
    @category_filter = nil if @category_filter.to_i == 0

    session[:expenses_payment_method] = params[:payment_method] || nil
    @payment_method_filter = session[:expenses_payment_method]
    @payment_method_filter = nil if @payment_method_filter.blank?

    session[:expenses_card_id] = params[:card_id] if params[:card_id].present?
    @card_filter = session[:expenses_card_id]
    @card_filter = nil if @card_filter.to_i == 0

    session[:expenses_paid] = params[:paid] if params.key?(:paid)
    @paid_filter = session[:expenses_paid]
    @paid_filter = nil if @paid_filter.blank?

    @expenses = expanded_expenses

    filter_by_month
    filter_by_category
    filter_by_payment_method
    filter_by_card
    filter_by_paid
    filter_by_description

    calculate_totals
    calculate_net_balance
  end

  def filter_by_month
    return if @month.nil? || @year.nil?

    @expenses.select! do |expense|
      expense.balance_month.month == @month && expense.balance_month.year == @year
    end
  end

  def filter_by_category
    return if @category_filter.nil?

    @expenses.select! do |expense|
      expense.category_id.to_s == @category_filter.to_s
    end
  end

  def filter_by_payment_method
    return if @payment_method_filter.nil?

    @expenses.select! do |expense|
      expense.payment_method == @payment_method_filter
    end
  end

  def filter_by_card
    return if @card_filter.nil?

    @expenses.select! do |expense|
      expense.card_id.to_s == @card_filter.to_s
    end
  end

  def filter_by_paid
    return if @paid_filter.nil?

    value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
    @expenses.select! { |expense| expense.paid == value }
  end

  def filter_by_description
    return if @description_filter.blank?

    @expenses.select! do |expense|
      expense.description.to_s.downcase.include?(@description_filter.downcase)
    end
  end

  def calculate_totals
    @total_amount = @expenses.sum(&:amount)
    @total_paid = @expenses.select(&:paid?).sum(&:amount)
    @total_unpaid = @expenses.reject(&:paid?).sum(&:amount)
  end

  def calculate_net_balance
    return unless @month.present? && @year.present?

    current_month_start = Date.new(@year, @month, 1)
    previous_month_end = current_month_start - 1.day
    current_month_end = current_month_start.end_of_month

    receitas_anteriores = Income.where("balance_month <= ?", previous_month_end).sum(:amount)
    despesas_anteriores = Expense.where("balance_month <= ?", previous_month_end).sum(:amount)
    @previous_balance = receitas_anteriores - despesas_anteriores

    receitas_pag = Income.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)
    despesas_pag = Expense.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)

    @net_balance = receitas_pag - despesas_pag
  end

  def create_recurring_expenses(expense)
    repetir = expense.repetir.to_i
    return if repetir <= 0

    repetir.times do |i|
      Expense.create!(
        description: expense.description,
        amount: expense.amount,
        category_id: expense.category_id,
        payment_method: expense.payment_method,
        card_id: expense.card_id,
        date: expense.date + (i + 1).month,
        balance_month: expense.balance_month + (i + 1).month,
        installments_count: expense.installments_count,
        current_installment: expense.current_installment,
        paid: false
      )
    end
  end

  def expanded_expenses
    Expense.includes(:category, :card)
           .order(balance_month: :desc, date: :asc, current_installment: :asc)
           .to_a
  end
end
