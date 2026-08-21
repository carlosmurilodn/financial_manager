class IncomesController < ApplicationController
  before_action :set_income, only: %i[show edit update destroy toggle_paid]

  def index
    load_incomes
  end

  def show; end

  def new
    @income = current_user.incomes.new
  end

  def create
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
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
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
    load_incomes
    success_message = "Status da receita atualizado com sucesso!"

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
    redirect_to incomes_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def set_income
    @income = current_user.incomes.find(params[:id])
  end

  def income_params
    permitted = params.require(:income).permit(:amount, :description, :date, :balance_month, :paid, :repetir, :category_id)
    permitted[:amount] = parse_brazilian_amount(permitted[:amount])
    normalize_category_reference(permitted)
    permitted
  end

  def normalize_category_reference(permitted)
    return if permitted[:category_id].blank?

    permitted[:category_id] = nil unless current_user.categories.exists?(id: permitted[:category_id])
  end

  def load_incomes
    load_income_filters
    result = Incomes::IndexQuery.new(user: current_user, filters: income_filters).call

    @incomes = sort_collection(result.incomes, sort_map: income_sort_map, default_sort: "balance_month")
    assign_income_result(result)
    paginate_incomes if action_name == "index"
  end

  def load_income_filters
    session[:incomes_month] = params[:month].to_i if params[:month].present?
    @month = session[:incomes_month]
    @month = nil if @month.blank? || @month == 0

    session[:incomes_year] = params[:year].to_i if params[:year].present?
    @year = session[:incomes_year]
    @year = nil if @year.blank? || @year == 0

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
      "description" => ->(income) { income.description.to_s },
      "category" => ->(income) { income.category&.display_name.to_s },
      "amount" => ->(income) { income.amount.to_d },
      "date" => ->(income) { income.date },
      "balance_month" => ->(income) { income.balance_month },
      "paid" => ->(income) { income.paid? }
    }
  end

  def paginate_incomes
    @per_page = pagination_per_page(:incomes_per_page)
    @incomes = paginate_collection(@incomes, per_page: @per_page)

    @item_offset = ((@current_page.to_i - 1) * @per_page.to_i)
  end
end
