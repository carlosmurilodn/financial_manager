class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    load_incomes
  end

  def show; end

  def new
    @income = current_user.incomes.new(date: Date.current, balance_month: Date.current.beginning_of_month)
    prepare_income_duplication if params[:duplicate_from].present?
  end

  def create
    if params[:incomes].present?
      @income_rows = multiple_income_params
      @income = current_user.incomes.new

      if @income_rows.blank?
        @income.errors.add(:base, "Informe ao menos uma receita.")
        render_new_income_with_errors
        return
      end

      ActiveRecord::Base.transaction do
        @income_rows.each { |attributes| create_income!(attributes) }
      end

      redirect_to incomes_path, notice: "Receitas criadas com sucesso!"
      return
    end

    attributes = income_params
    @income = current_user.incomes.new(attributes)
    @income.repetir ||= 0

    assign_income_dates(attributes)

    if @income.save
      Incomes::CreateRecurring.call(income: @income, user: current_user)
      success_message = "Receita criada com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(incomes_path)
        end

        format.html { redirect_to incomes_path, notice: success_message }
      end
    else
      render_new_income_with_errors
    end
  rescue ActiveRecord::RecordInvalid => error
    @income = error.record
    render_new_income_with_errors
  end

  def edit; end

  def update
    attributes = income_params
    assign_income_dates(attributes)

    if @income.update(attributes.except(:date, :balance_month))
      success_message = "Receita atualizada com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(incomes_path)
        end
        format.html { redirect_to incomes_path, notice: success_message }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, formats: [ :html ], status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @income.destroy
    load_incomes
    success_message = "Receita removida com sucesso!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("incomes-table", partial: "incomes_table"),
          turbo_stream.replace("incomes-hero-kpis", partial: "hero_kpis"),
          turbo_flash_stream(success_message)
        ]
      end
      format.html { redirect_to incomes_path, notice: success_message }
    end
  end

  def toggle_paid
    @income.update(paid: !@income.paid)
    success_message = "Status da receita atualizado com sucesso!"

    if params[:return_to] == "show"
      redirect_to income_path(@income), notice: success_message
      return
    end

    load_incomes

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("income_#{@income.id}", partial: "income_row", locals: { income: @income }),
          turbo_stream.replace("incomes-hero-kpis", partial: "hero_kpis"),
          turbo_flash_stream(success_message)
        ]
      end
      format.html { redirect_to incomes_path, notice: success_message }
    end
  end

  def clear_filters
    session.delete(:incomes_month)
    session.delete(:incomes_year)
    session.delete(:incomes_description)
    session.delete(:incomes_paid)
    session.delete(:incomes_category_id)
    session.delete(:incomes_amount_min)
    session.delete(:incomes_amount_max)
    session.delete(:incomes_sort_option)
    redirect_to incomes_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def prepare_income_duplication
    source = current_user.incomes.find(params[:duplicate_from])

    @income_rows = [ {
      description: source.description,
      amount: source.amount,
      date: Date.current,
      balance_month: Date.current.beginning_of_month,
      category_id: source.category_id,
      paid: false,
      repetir: 0
    } ]
  end

  def set_income
    @income = current_user.incomes.find(params[:id])
  end

  def income_params
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid, :repetir, :category_id)
    permitted[:amount] = parse_brazilian_amount(permitted[:amount])
    normalize_category_reference(permitted)
    permitted
  end

  def multiple_income_params
    params.require(:incomes).to_unsafe_h.values.filter_map do |raw_attributes|
      attributes = ActionController::Parameters.new(raw_attributes).permit(
        :amount, :description, :date, :balance_month, :paid, :repetir, :category_id
      )

      normalize_category_reference(attributes)
      attributes if income_row_present?(attributes)
    end
  end

  def income_row_present?(attributes)
    attributes[:description].present? ||
      parse_brazilian_amount(attributes[:amount], blank: 0).positive? ||
      attributes[:category_id].present? ||
      ActiveModel::Type::Boolean.new.cast(attributes[:paid]) ||
      attributes[:repetir].to_i.positive?
  end

  def create_income!(attributes)
    income = current_user.incomes.new(
      attributes.except(:amount, :date, :balance_month).merge(
        amount: parse_brazilian_amount(attributes[:amount]),
        date: parse_brazilian_date(attributes[:date]),
        balance_month: parse_brazilian_date(attributes[:balance_month]),
        repetir: attributes[:repetir].presence || 0
      )
    )
    income.save!
    Incomes::CreateRecurring.call(income: income, user: current_user)
  end

  def render_new_income_with_errors
    respond_to do |format|
      format.turbo_stream { render :new, formats: [ :html ], status: :unprocessable_entity }
      format.html { render :new, status: :unprocessable_entity }
    end
  end

  def normalize_category_reference(permitted)
    return if permitted[:category_id].blank?

    permitted[:category_id] = nil unless current_user.categories.exists?(id: permitted[:category_id])
  end

  def load_incomes
    load_income_filters
    result = Incomes::IndexQuery.new(user: current_user, filters: income_filters).call

    sort_config = selected_income_sort_config
    @incomes = sort_collection(
      result.incomes,
      sort_map: income_sort_map,
      default_sort: sort_config[:sort],
      default_direction: sort_config[:direction],
      sort: sort_config[:sort],
      direction: sort_config[:direction]
    )

    assign_income_result(result)
    paginate_incomes if action_name == "index"
  end

  def load_income_filters
    session[:incomes_month] = params[:month].to_i if params[:month].present?
    @month = session[:incomes_month]
    @month = nil if @month.blank? || @month == 0
    @month ||= Date.current.month

    session[:incomes_year] = params[:year].to_i if params[:year].present?
    @year = session[:incomes_year]
    @year = nil if @year.blank? || @year == 0
    @year ||= Date.current.year

    session[:incomes_description] = params[:description].to_s.strip if params[:description].present?
    @description_filter = session[:incomes_description].presence

    session[:incomes_paid] = params[:paid] if params.key?(:paid)
    @paid_filter = session[:incomes_paid]
    @paid_filter = nil if @paid_filter.blank?

    session[:incomes_category_id] = params[:category_id] if params[:category_id].present?
    @category_filter = session[:incomes_category_id]
    @category_filter = nil if @category_filter.to_i == 0

    session[:incomes_amount_min] = params[:amount_min].to_s.strip if params.key?(:amount_min)
    @amount_min_filter = session[:incomes_amount_min].presence

    session[:incomes_amount_max] = params[:amount_max].to_s.strip if params.key?(:amount_max)
    @amount_max_filter = session[:incomes_amount_max].presence

    @item_offset = 0
  end

  def income_filters
    {
      month: @month,
      year: @year,
      description: @description_filter,
      paid: @paid_filter,
      category_id: @category_filter,
      amount_min: @amount_min_filter,
      amount_max: @amount_max_filter
    }
  end

  def assign_income_result(result)
    @total_amount = result.total_amount
    @total_received = result.total_received
    @total_pending = result.total_pending
    @previous_balance = result.previous_balance
    @current_balance = result.current_balance
  end

  def assign_income_dates(attributes)
    @income.date = parse_brazilian_date(attributes[:date])
    @income.balance_month = parse_brazilian_date(attributes[:balance_month])
  end

  def income_sort_map
    {
      "created_at" => ->(income) { income.created_at },
      "amount" => ->(income) { income.amount.to_d },
      "date" => ->(income) { income.date }
    }
  end

  def paginate_incomes
    @per_page = pagination_per_page(:incomes_per_page)
    @incomes = paginate_collection(@incomes, per_page: @per_page)

    @item_offset = ((@current_page.to_i - 1) * @per_page.to_i)
  end

  def selected_income_sort_config
    session[:incomes_sort_option] = params[:sort_option] if params[:sort_option].present?
    @sort_option = session[:incomes_sort_option].presence || IncomesHelper::DEFAULT_INCOME_SORT_OPTION
    @sort_option = IncomesHelper::DEFAULT_INCOME_SORT_OPTION unless IncomesHelper::INCOME_SORT_OPTIONS.key?(@sort_option)
    session[:incomes_sort_option] = @sort_option

    IncomesHelper::INCOME_SORT_OPTIONS.fetch(@sort_option)
  end
end
