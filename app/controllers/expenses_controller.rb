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
    @expense = current_user.expenses.new
  end

  def edit; end

  def delete_options; end

  def toggle_paid_options; end

  def create
    if params[:expenses].present?
      expense_rows = multiple_expenses_params
      @expense = current_user.expenses.new

      if expense_rows.blank?
        @expense.errors.add(:base, "Informe ao menos uma despesa.")
        render_new_expense_with_errors
        return
      end

      create_multiple_expenses!(expense_rows)
      success_message = "Despesas criadas com sucesso!"

      respond_to do |format|
        format.html { redirect_to expenses_path, notice: success_message }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_flash_stream(success_message)
          ]
        end
      end
    else
      @expense = build_expense(expense_params, params[:expense])

      if @expense.save
        create_recurring_expenses(@expense)

        success_message = "Despesa criada com sucesso!"

        respond_to do |format|
          format.html { redirect_to expenses_path, notice: success_message }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update("modal", ""),
              turbo_flash_stream(success_message)
            ]
          end
        end
      else
        render_new_expense_with_errors
      end
    end
  rescue ActiveRecord::RecordInvalid => error
    @expense = error.record.is_a?(Expense) ? error.record : current_user.expenses.new

    render_new_expense_with_errors
  end

  def update
    @expense.amount = parse_brazilian_amount(params[:expense][:amount], blank: 0)
    assign_expense_dates

    if update_expense_and_group
      respond_to do |format|
        success_message = "Despesa atualizada com sucesso!"

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_flash_stream(success_message)
          ]
        end

        format.html do
          redirect_to expenses_path, notice: success_message
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, formats: [ :html ], status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_expense_with_scope
    load_expenses
    success_message = "Despesa removida com sucesso!"

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = success_message
        render :destroy
      end
      format.html { redirect_to expenses_path, notice: success_message }
    end
  end

  def toggle_paid
    toggle_paid_with_scope
    load_expenses

    success_message = "Status da despesa atualizado com sucesso!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("expenses-table", partial: "expenses_table"),
          turbo_stream.replace("expenses-hero-kpis", partial: "hero_kpis"),
          turbo_stream.update("modal", ""),
          turbo_flash_stream(success_message)
        ]
      end
      format.html { redirect_to expenses_path(request.query_parameters.except(:paid_scope)), notice: success_message }
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
    session.delete(:expenses_amount_min)
    session.delete(:expenses_amount_max)
    session.delete(:expenses_installment)

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
      amount_min: @amount_min_filter,
      amount_max: @amount_max_filter,
      installment: @installment_filter,
      sort: @sort,
      direction: @direction,
      sort_option: @sort_option,
      per_page: @per_page,
      page: params[:page]
    }.compact_blank
  end

  def render_new_expense_with_errors
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream do
        render :new, formats: [ :html ], status: :unprocessable_entity
      end
    end
  end

  def set_expense
    @expense = current_user.expenses.find(params[:id])
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
    expense = current_user.expenses.new(attributes.except(:amount, :date, :balance_month))
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
    @month ||= Date.current.month

    session[:expenses_year] = params[:year].to_i if params[:year].present?
    @year = session[:expenses_year]
    @year = nil if @year.blank? || @year == 0
    @year ||= Date.current.year

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

    session[:expenses_amount_min] = params[:amount_min].to_s.strip if params.key?(:amount_min)
    @amount_min_filter = session[:expenses_amount_min].presence

    session[:expenses_amount_max] = params[:amount_max].to_s.strip if params.key?(:amount_max)
    @amount_max_filter = session[:expenses_amount_max].presence

    session[:expenses_installment] = params[:installment] if params.key?(:installment)
    @installment_filter = session[:expenses_installment]
    @installment_filter = nil if @installment_filter.blank?

    result = Expenses::IndexQuery.new(user: current_user, filters: expense_filters).call
    assign_expense_result(result)

    sort_config = selected_expense_sort_config
    @expenses = sort_collection(
      @expenses,
      sort_map: expense_sort_map,
      default_sort: sort_config[:sort],
      default_direction: sort_config[:direction],
      sort: sort_config[:sort],
      direction: sort_config[:direction]
    )

    paginate_expenses if action_name == "index"
  end

  def expense_filters
    {
      description: @description_filter,
      month: @month,
      year: @year,
      category_id: @category_filter,
      payment_method: @payment_method_filter,
      card_id: @card_filter,
      paid: @paid_filter,
      amount_min: @amount_min_filter,
      amount_max: @amount_max_filter,
      installment: @installment_filter
    }
  end

  def assign_expense_result(result)
    @expenses = result.expenses
    @total_amount = result.total_amount
    @total_paid = result.total_paid
    @total_unpaid = result.total_unpaid
    @previous_balance = result.previous_balance
    @net_balance = result.net_balance
  end

  def create_recurring_expenses(expense)
    repetir = expense.repetir.to_i
    return if repetir <= 0

    repetir.times do |i|
      current_user.expenses.create!(
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
    return expense.date unless expense.card_payment_method?

    expense.card&.billing_due_date_for(expense.date) || expense.date
  end

  def expense_sort_map
    {
      "description" => ->(expense) { expense.description.to_s },
      "installment" => ->(expense) { expense.current_installment.to_i },
      "amount" => ->(expense) { expense.effective_amount.to_d },
      "date" => ->(expense) { expense.date },
      "balance_month" => ->(expense) { expense.balance_month },
      "created_at" => ->(expense) { expense.created_at },
      "category" => ->(expense) { expense.category&.display_name.to_s },
      "payment_method" => ->(expense) { expense.payment_method.to_s },
      "card" => ->(expense) { expense.card&.name.to_s },
      "paid" => ->(expense) { expense.paid? }
    }
  end

  def selected_expense_sort_config
    session[:expenses_sort_option] = params[:sort_option] if params[:sort_option].present?
    @sort_option = session[:expenses_sort_option].presence || ExpensesHelper::DEFAULT_EXPENSE_SORT_OPTION
    @sort_option = ExpensesHelper::DEFAULT_EXPENSE_SORT_OPTION unless ExpensesHelper::EXPENSE_SORT_OPTIONS.key?(@sort_option)
    session[:expenses_sort_option] = @sort_option

    ExpensesHelper::EXPENSE_SORT_OPTIONS.fetch(@sort_option)
  end

  def paginate_expenses
    @expenses = paginate_collection(@expenses, per_page: pagination_per_page(:expenses_per_page))
  end
end
