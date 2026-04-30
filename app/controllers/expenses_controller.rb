class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy toggle_paid delete_options toggle_paid_options]
  helper_method :expenses_filter_params

  def index
    load_expenses
  end

  def report
    load_expenses
  end

  def show; end

  def new
    @expense = Expense.new
  end

  def edit; end

  def import_invoice
    load_invoice_import_options
    @invoice_preview_items = []
    @invoice_import_errors = []
  end

  def analyze_invoice
    load_invoice_import_options
    @selected_card_id = params[:card_id]
    @invoice_due_date = params[:due_date]

    result = InvoiceImportAnalyzer.new(
      file: params[:invoice_file],
      card_id: @selected_card_id,
      due_date: @invoice_due_date,
      invoice_password: params[:invoice_password],
      categories: @categories
    ).call

    @invoice_preview_items = result.items
    @invoice_import_errors = result.errors

    render :import_invoice
  end

  def confirm_invoice_import
    importable_items = invoice_import_items.select do |item|
      ActiveModel::Type::Boolean.new.cast(item[:selected])
    end

    if importable_items.blank?
      load_invoice_import_options
      @invoice_preview_items = invoice_import_items
      @invoice_import_errors = ["Selecione ao menos um lançamento para importar."]
      render :import_invoice, status: :unprocessable_entity
      return
    end

    created_count = create_invoice_expenses(importable_items)
    success_message = "#{created_count} lançamentos importados com sucesso!"
    flash[:notice] = success_message

    respond_to do |format|
      format.html { redirect_to expenses_path, notice: success_message }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("modal", "")
      end
    end
  rescue ActiveRecord::RecordInvalid => error
    load_invoice_import_options
    @invoice_preview_items = invoice_import_items
    @invoice_import_errors = ["Revise os lançamentos: #{error.record.errors.full_messages.to_sentence}"]
    render :import_invoice, status: :unprocessable_entity
  end

  def delete_options; end

  def toggle_paid_options; end

  def create
    if params[:expenses].present?
      expense_rows = multiple_expenses_params
      @expense = Expense.new

      if expense_rows.blank?
        @expense.errors.add(:base, "Informe ao menos uma despesa.")
        render_new_expense_with_errors
        return
      end

      create_multiple_expenses!(expense_rows)

      respond_to do |format|
        format.html { redirect_to expenses_path, notice: "Despesas criadas com sucesso!" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("modal", "")
        end
      end
    else
      @expense = build_expense(expense_params, params[:expense])

      if @expense.save
        create_recurring_expenses(@expense)

        respond_to do |format|
          format.html { redirect_to expenses_path, notice: "Despesa criada com sucesso!" }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("modal", "")
          end
        end
      else
        render_new_expense_with_errors
      end
    end
  rescue ActiveRecord::RecordInvalid => error
    @expense = error.record.is_a?(Expense) ? error.record : Expense.new

    render_new_expense_with_errors
  end

  def update
    @expense.amount = parse_brazilian_amount(params[:expense][:amount], blank: 0)
    assign_expense_dates

    if update_expense_and_group
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
    destroy_expense_with_scope
    load_expenses

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expenses_path, notice: "Despesa removida com sucesso!" }
    end
  end

  def toggle_paid
    toggle_paid_with_scope
    load_expenses

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("expenses-table", partial: "expenses_table"),
          turbo_stream.replace("expenses-hero-kpis", partial: "hero_kpis"),
          turbo_stream.update("modal", "")
        ]
      end
      format.html { redirect_to expenses_path(request.query_parameters.except(:paid_scope)) }
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

  def expenses_filter_params
    {
      description: @description_filter,
      month: @month,
      year: @year,
      category_id: @category_filter,
      payment_method: @payment_method_filter,
      card_id: @card_filter,
      paid: @paid_filter,
      sort: @sort,
      direction: @direction,
      per_page: @per_page,
      page: params[:page]
    }.compact_blank
  end

  def render_new_expense_with_errors
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream do
        render :new, formats: [:html], status: :unprocessable_entity
      end
    end
  end

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def load_invoice_import_options
    @cards = Card.order(:name)
    @categories = Category.all.sort_by(&:sort_name)
  end

  def invoice_import_items
    raw_items = params[:invoice_items] || {}
    raw_items = raw_items.permit!.to_h if raw_items.respond_to?(:permit!)
    raw_items.values.map(&:symbolize_keys)
  end

  def create_invoice_expenses(items)
    Expense.transaction do
      items.each do |item|
        Expense.create!(
          description: item[:description],
          amount: parse_brazilian_amount(item[:amount], blank: 0),
          date: parse_invoice_date(item[:date]),
          balance_month: parse_invoice_date(item[:due_date]) || parse_invoice_date(item[:date]),
          category_id: item[:category_id],
          payment_method: item[:payment_method],
          card_id: item[:card_id].presence,
          paid: false,
          installments_count: 1,
          current_installment: 1
        )
      end
    end

    items.size
  end

  def parse_invoice_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    parse_brazilian_date(value)
  end

  def expense_params
    params.require(:expense).permit(
      :amount, :description, :date, :balance_month,
      :category_id, :payment_method, :card_id, :paid,
      :installments_count, :current_installment, :repetir
    )
  end

  def multiple_expenses_params
    return [] unless params[:expenses].present?

    params.require(:expenses).to_unsafe_h.values.filter_map do |raw_attributes|
      attributes = ActionController::Parameters.new(raw_attributes).permit(
        :amount, :description, :date, :balance_month,
        :category_id, :payment_method, :card_id, :paid,
        :installments_count, :current_installment, :repetir
      )

      attributes if expense_row_present?(attributes)
    end
  end

  def expense_row_present?(attributes)
    attributes[:description].present? ||
      parse_brazilian_amount(attributes[:amount], blank: 0).positive? ||
      attributes[:date].present? ||
      attributes[:balance_month].present? ||
      attributes[:category_id].present? ||
      attributes[:payment_method].present? ||
      attributes[:card_id].present?
  end

  def create_multiple_expenses!(expense_rows = multiple_expenses_params)
    Expense.transaction do
      expense_rows.each do |attributes|
        expense = build_expense(attributes, attributes)
        expense.save!
        create_recurring_expenses(expense)
      end
    end
  end

  def build_expense(attributes, raw_attributes)
    expense = Expense.new(attributes.except(:amount, :date, :balance_month))
    expense.amount = parse_brazilian_amount(raw_attributes[:amount], blank: 0)
    expense.date = parse_brazilian_date(raw_attributes[:date])
    expense.balance_month = parse_brazilian_date(raw_attributes[:balance_month]) || default_balance_month_for(expense)
    expense.repetir ||= 0
    expense
  end

  def assign_expense_dates
    @expense.date = parse_brazilian_date(expense_params[:date])
    @expense.balance_month = parse_brazilian_date(expense_params[:balance_month])
  end

  def update_expense_and_group
    Expense.transaction do
      @expense.assign_attributes(expense_params.except(:amount, :date, :balance_month))
      @expense.save!
      @expense.sync_future_group_expenses! if apply_to_group?
    end

    true
  rescue ActiveRecord::RecordInvalid => error
    @expense = error.record if error.record.is_a?(Expense) && error.record.id == @expense.id
    false
  end

  def apply_to_group?
    params[:update_scope] == "group"
  end

  def destroy_expense_with_scope
    Expense.transaction do
      if params[:delete_scope] == "group"
        @expense.destroy_from_current_onward!
      else
        @expense.destroy!
      end
    end
  end

  def toggle_paid_with_scope
    Expense.transaction do
      if params[:paid_scope] == "group"
        @expense.toggle_paid_from_current_onward!
      else
        @expense.update!(paid: !@expense.paid)
      end
    end
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

    @expenses = sort_collection(@expenses, sort_map: expense_sort_map, default_sort: "balance_month", default_direction: "desc")

    calculate_totals
    calculate_net_balance
    paginate_expenses if action_name == "index"
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

  def default_balance_month_for(expense)
    return if expense.date.blank?
    return expense.date unless expense.payment_method_credito_a_vista? || expense.payment_method_credito_parcelado?

    expense.card&.billing_due_date_for(expense.date) || expense.date
  end

  def expanded_expenses
    Expense.includes(:category, :card)
           .order(balance_month: :desc, date: :asc, current_installment: :asc)
           .to_a
  end

  def expense_sort_map
    {
      "description" => ->(expense) { expense.description.to_s },
      "installment" => ->(expense) { expense.current_installment.to_i },
      "amount" => ->(expense) { expense.amount.to_d },
      "date" => ->(expense) { expense.date },
      "balance_month" => ->(expense) { expense.balance_month },
      "category" => ->(expense) { expense.category&.display_name.to_s },
      "payment_method" => ->(expense) { expense.payment_method.to_s },
      "card" => ->(expense) { expense.card&.name.to_s },
      "paid" => ->(expense) { expense.paid? }
    }
  end

  def paginate_expenses
    @expenses = paginate_collection(@expenses, per_page: pagination_per_page(:expenses_per_page))
  end
end
