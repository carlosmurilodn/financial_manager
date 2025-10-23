class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy toggle_paid]

  def index
    load_expenses
  end

  def show; end
  def new; @expense = Expense.new; end

  def create
    @expense = Expense.new(expense_params)
    @expense.amount = normalize_amount(params[:expense][:amount])
    @expense.repetir ||= 0

    # Converter datas
    @expense.date = Date.strptime(expense_params[:date], "%d/%m/%Y") rescue nil
    @expense.balance_month = Date.strptime(expense_params[:balance_month], "%d/%m/%Y") rescue nil

    if @expense.save
      gerar_repeticoes(@expense)
      @expense.generate_future_installments if @expense.payment_method_credito_parcelado?

      respond_to do |format|
        # HTML normal
        format.html { redirect_to expenses_path, notice: "Despesa criada com sucesso!" }

        # Turbo: apenas retorna vazio, JS vai fechar e recarregar
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
    @expense.amount = normalize_amount(params[:expense][:amount])

    if @expense.update(expense_params.except(:amount))
      if @expense.payment_method_credito_parcelado?
        @expense.installments.where("number > ?", @expense.current_installment).destroy_all
        @expense.generate_future_installments
      end

      respond_to do |format|
        # Fecha o modal se estiver vindo via Turbo
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("modal", "")
        end

        # Fallback normal (recarrega a página)
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

      # Se quiser filtrar (ex: por data, categoria, pago, etc.), use:
      # @expenses = Expense.filter_by_params(params)

      # Renderiza HTML para string usando a view PDF
      html = render_to_string(
        template: "expenses/report_pdf",
        layout: "pdf"
      )

      # Opções PDFKit — mesmas da previsão financeira
      pdf_options = {
        page_size: "A4",
        orientation: "Landscape",
        print_media_type: true,
        encoding: "UTF-8",
        disable_smart_shrinking: false,
        quiet: true,
        root_url: request.base_url
      }

      # Gera e envia o PDF
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
      :installments_count, :current_installment, :is_parent, :repetir
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
  # Carrega despesas e aplica filtros via params + session
  # --------------------------
  def load_expenses
    # --------------------------
    # Mês
    # --------------------------
    session[:expenses_month] = params[:month].to_i if params[:month].present?
    @month = session[:expenses_month]
    @month = nil if @month.blank? || @month == 0   # "Todos"

    # --------------------------
    # Ano
    # --------------------------
    session[:expenses_year] = params[:year].to_i if params[:year].present?
    @year = session[:expenses_year]
    @year = nil if @year.blank? || @year == 0     # "Todos"

    # --------------------------
    # Descrição
    # --------------------------
    session[:expenses_description] = params[:description]&.strip
    @description_filter = session[:expenses_description].presence

    # --------------------------
    # Categoria
    # --------------------------
    session[:expenses_category_id] = params[:category_id] if params[:category_id].present?
    @category_filter = session[:expenses_category_id]
    @category_filter = nil if @category_filter.to_i == 0  # "Todas"

    # --------------------------
    # Método de pagamento
    # --------------------------
    session[:expenses_payment_method] = params[:payment_method] || nil
    @payment_method_filter = session[:expenses_payment_method]
    @payment_method_filter = nil if @payment_method_filter.blank?  # "Todos"

    # --------------------------
    # Cartão
    # --------------------------
    session[:expenses_card_id] = params[:card_id] if params[:card_id].present?
    @card_filter = session[:expenses_card_id]
    @card_filter = nil if @card_filter.to_i == 0  # "Todos"

    # --------------------------
    # Pago
    # --------------------------
    session[:expenses_paid] = params[:paid] if params.key?(:paid)
    @paid_filter = session[:expenses_paid]
    @paid_filter = nil if @paid_filter.blank?  # "Todas"

    # --------------------------
    # Carregar despesas
    # --------------------------
    @expenses = []
    Expense.order(balance_month: :desc, date: :asc).each do |expense|
      @expenses << expense
      if expense.payment_method_credito_parcelado? && expense.installments.any?
        expense.installments.order(:number).each { |inst| @expenses << inst }
      end
    end
    # --------------------------
    # Aplicar filtros
    # --------------------------
    filter_by_month
    filter_by_category
    filter_by_payment_method
    filter_by_card
    filter_by_paid
    filter_by_description
    # --------------------------
    # Totais
    # --------------------------
    calculate_totals
    calculate_net_balance
  end
  
  # --------------------------
  # Filtros
  # --------------------------
  def filter_by_month
    return if @month.nil? || @year.nil?
    @expenses.select! do |e|
      date_to_check = e.respond_to?(:due_date) ? e.due_date : e.balance_month
      date_to_check.month == @month && date_to_check.year == @year
    end
  end

  def filter_by_category
    return if @category_filter.nil?
    @expenses.select! do |e|
      category_id = e.is_a?(Installment) ? e.expense.category_id : e.category_id
      category_id.to_s == @category_filter.to_s
    end
  end

  def filter_by_payment_method
    return if @payment_method_filter.nil?
    @expenses.select! do |e|
      method = e.is_a?(Installment) ? e.expense.payment_method : e.payment_method
      method == @payment_method_filter
    end
  end


  def filter_by_card
    return if @card_filter.nil?
    @expenses.select! do |e|
      card_id = e.is_a?(Installment) ? e.expense.card_id : e.card_id
      card_id.to_s == @card_filter.to_s
    end
  end

  def filter_by_paid
    return if @paid_filter.nil?
    value = ActiveModel::Type::Boolean.new.cast(@paid_filter)
    @expenses.select! do |e|
      paid_status = e.is_a?(Installment) ? e.paid : e.paid
      paid_status == value
    end
  end


  def filter_by_description
    return if @description_filter.blank?

    @expenses.select! do |e|
      description = e.is_a?(Installment) ? e.expense.description : e.description
      description.to_s.downcase.include?(@description_filter.downcase)
    end
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

    current_month_start = Date.new(@year, @month, 1)
    previous_month_end = current_month_start - 1.day
    current_month_end = current_month_start.end_of_month

    # --- Saldo do mês anterior (todas as receitas e despesas até mês anterior) ---
    receitas_anteriores = Income.where("balance_month <= ?", previous_month_end).sum(:amount)
    despesas_anteriores = Expense.where("balance_month <= ?", previous_month_end).sum(:amount) +
                          Installment.where("balance_month <= ?", previous_month_end).sum(:amount)
    @previous_balance = receitas_anteriores - despesas_anteriores

    # --- Saldo atual (somente receitas e parcelas pagas) ---
    receitas_pag = Income.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)
    despesas_pag = Expense.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount) +
                  Installment.where("balance_month <= ? AND paid = ?", current_month_end, true).sum(:amount)

    # Saldo líquido
    @net_balance = receitas_pag - despesas_pag
  end


  def gerar_repeticoes(expense)
    # Garante que repetir seja inteiro
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
        balance_month: expense.balance_month + (i + 1).month, # 👈 obrigatório!
        paid: false
      )
    end
  end
end