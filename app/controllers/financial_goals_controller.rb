class FinancialGoalsController < ApplicationController
  before_action :set_financial_goal, only: %i[edit update destroy]

  def index
    load_financial_goals
  end

  def new
    @financial_goal = current_user.financial_goals.new
    load_categories
    load_resource_cards
    build_resource_rows
  end

  def create
    @financial_goal = current_user.financial_goals.new(financial_goal_params)

    if @financial_goal.save
      success_message = "Objetivo criado com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(financial_goals_path)
        end

        format.html { redirect_to financial_goals_path, notice: success_message }
      end
    else
      load_categories
      load_resource_cards
      build_resource_rows
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    load_categories
    load_resource_cards
    build_resource_rows
  end

  def update
    if @financial_goal.update(financial_goal_params)
      success_message = "Objetivo atualizado com sucesso!"

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = success_message
          render turbo_stream: turbo_visit_stream(financial_goals_path)
        end
        format.html { redirect_to financial_goals_path, notice: success_message }
      end
    else
      load_categories
      load_resource_cards
      build_resource_rows
      respond_to do |format|
        format.turbo_stream { render :edit, formats: [ :html ], status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @financial_goal.destroy
    load_financial_goals
    success_message = "Objetivo removido com sucesso!"

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = success_message
        render :destroy
      end
      format.html { redirect_to financial_goals_path, notice: success_message }
    end
  end

  def clear_filters
    session.delete(:financial_goals_description)
    session.delete(:financial_goals_category_id)
    session.delete(:financial_goals_progress_min)
    session.delete(:financial_goals_current_amount_min)
    session.delete(:financial_goals_target_amount_min)
    session.delete(:financial_goals_credit_amount_min)
    session.delete(:financial_goals_potential_amount_min)
    session.delete(:financial_goals_remaining_amount_max)
    session.delete(:financial_goals_monthly_amount_max)
    session.delete(:financial_goals_due_until)
    session.delete(:financial_goals_status)
    session.delete(:financial_goals_priority)

    redirect_to financial_goals_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def load_financial_goals
    goals = current_user.financial_goals.includes(:category, :financial_goal_resources).to_a

    load_categories
    load_financial_goal_filters
    goals = apply_financial_goal_filters(goals)

    @financial_goals_count = goals.size
    @financial_goals_active_count = goals.count { |goal| goal.status_planned? || goal.status_in_progress? }
    @financial_goals_target_total = goals.sum { |goal| goal.target_amount.to_d }
    @financial_goals_current_total = goals.sum(&:progress_amount)
    @financial_goals_nearest_due_date = goals.reject(&:status_completed?).map(&:due_date).compact.min

    goals = sort_collection(goals, sort_map: financial_goal_sort_map, default_sort: "due_date")
    @financial_goals = paginate_collection(goals, per_page: pagination_per_page(:financial_goals_per_page))
  end

  def financial_goal_sort_map
    {
      "description" => ->(goal) { goal.description.to_s },
      "category" => ->(goal) { goal.category&.display_name.to_s },
      "target_amount" => ->(goal) { goal.target_amount.to_d },
      "current_amount" => ->(goal) { goal.progress_amount },
      "credit_amount" => ->(goal) { goal.credit_limit_amount },
      "potential_amount" => ->(goal) { goal.potential_amount },
      "remaining_amount" => ->(goal) { goal.remaining_amount },
      "monthly_amount" => ->(goal) { goal.monthly_required_amount },
      "progress" => ->(goal) { goal.progress_percent },
      "due_date" => ->(goal) { goal.due_date },
      "status" => ->(goal) { goal.status_label },
      "priority" => ->(goal) { goal.priority_before_type_cast.to_i }
    }
  end

  def set_financial_goal
    @financial_goal = current_user.financial_goals.find(params[:id])
  end

  def financial_goal_params
    permitted = params.require(:financial_goal).permit(
      :description,
      :target_amount,
      :current_amount,
      :category_id,
      :due_date,
      :status,
      :priority,
      :color,
      :notes,
      financial_goal_resources_attributes: [
        :id,
        :resource_type,
        :description,
        :amount,
        :include_in_total,
        :source_type,
        :source_id,
        :notes,
        :_destroy
      ]
    )

    permitted[:target_amount] = parse_brazilian_amount(permitted[:target_amount])
    permitted[:current_amount] = parse_brazilian_amount(permitted[:current_amount], blank: 0)
    normalize_category_reference(permitted)
    normalize_resource_amounts(permitted[:financial_goal_resources_attributes])
    permitted
  end

  def normalize_category_reference(permitted)
    return if permitted[:category_id].blank?

    permitted[:category_id] = nil unless current_user.categories.exists?(id: permitted[:category_id])
  end

  def normalize_resource_amounts(resources_attributes)
    return if resources_attributes.blank?

    resources_attributes.each_value do |resource_attributes|
      resource_attributes[:amount] = parse_brazilian_amount(resource_attributes[:amount], blank: 0)
      resource_attributes[:include_in_total] = ActiveModel::Type::Boolean.new.cast(resource_attributes[:include_in_total])
      normalize_resource_source(resource_attributes)
    end
  end

  def normalize_resource_source(resource_attributes)
    unless resource_attributes[:resource_type] == "credit_limit" && resource_attributes[:source_id].present?
      resource_attributes[:source_type] = nil
      resource_attributes[:source_id] = nil
      return
    end

    unless current_user.cards.exists?(id: resource_attributes[:source_id])
      resource_attributes[:source_type] = nil
      resource_attributes[:source_id] = nil
      return
    end

    resource_attributes[:source_type] = "Card"
  end

  def build_resource_rows
    @financial_goal.financial_goal_resources.build if @financial_goal.financial_goal_resources.empty?
  end

  def load_resource_cards
    @resource_cards = current_user.cards.order(Arel.sql("total_limit DESC NULLS LAST, name ASC"))
  end

  def load_categories
    @categories = current_user.categories.to_a.sort_by(&:sort_name)
  end

  def load_financial_goal_filters
    session[:financial_goals_description] = params[:description].to_s.strip if params.key?(:description)
    @description_filter = session[:financial_goals_description].presence

    session[:financial_goals_category_id] = params[:category_id] if params.key?(:category_id)
    @category_filter = session[:financial_goals_category_id]
    @category_filter = nil if @category_filter.to_i.zero?

    session[:financial_goals_progress_min] = params[:progress_min].to_s.strip if params.key?(:progress_min)
    @progress_min_filter = session[:financial_goals_progress_min].presence

    store_financial_goal_currency_filter(:financial_goals_current_amount_min, :current_amount_min)
    @current_amount_min_filter = session[:financial_goals_current_amount_min].presence

    store_financial_goal_currency_filter(:financial_goals_target_amount_min, :target_amount_min)
    @target_amount_min_filter = session[:financial_goals_target_amount_min].presence

    store_financial_goal_currency_filter(:financial_goals_credit_amount_min, :credit_amount_min)
    @credit_amount_min_filter = session[:financial_goals_credit_amount_min].presence

    store_financial_goal_currency_filter(:financial_goals_potential_amount_min, :potential_amount_min)
    @potential_amount_min_filter = session[:financial_goals_potential_amount_min].presence

    store_financial_goal_currency_filter(:financial_goals_remaining_amount_max, :remaining_amount_max)
    @remaining_amount_max_filter = session[:financial_goals_remaining_amount_max].presence

    store_financial_goal_currency_filter(:financial_goals_monthly_amount_max, :monthly_amount_max)
    @monthly_amount_max_filter = session[:financial_goals_monthly_amount_max].presence

    session[:financial_goals_due_until] = params[:due_until].presence if params.key?(:due_until)
    @due_until_filter = session[:financial_goals_due_until].presence

    session[:financial_goals_status] = params[:status].presence if params.key?(:status)
    @status_filter = session[:financial_goals_status].presence

    session[:financial_goals_priority] = params[:priority].presence if params.key?(:priority)
    @priority_filter = session[:financial_goals_priority].presence
  end

  def store_financial_goal_currency_filter(session_key, param_key)
    return unless params.key?(param_key)

    normalized_value = normalized_financial_goal_currency_filter(params[param_key])

    if normalized_value.present?
      session[session_key] = normalized_value
    else
      session.delete(session_key)
    end
  end

  def normalized_financial_goal_currency_filter(value)
    value = value.to_s.strip
    return nil if value.blank?

    amount = parse_brazilian_amount(value, blank: 0)
    return nil if amount.zero?

    value
  end

  def apply_financial_goal_filters(goals)
    filtered_goals = goals
    due_until_date = begin
      Date.parse(@due_until_filter) if @due_until_filter.present?
    rescue Date::Error
      nil
    end

    filtered_goals = filtered_goals.select { |goal| goal.description.to_s.downcase.include?(@description_filter.downcase) } if @description_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.category_id.to_s == @category_filter.to_s } if @category_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.progress_percent >= @progress_min_filter.to_f } if @progress_min_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.progress_amount >= parse_brazilian_amount(@current_amount_min_filter, blank: 0) } if @current_amount_min_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.target_amount.to_d >= parse_brazilian_amount(@target_amount_min_filter, blank: 0) } if @target_amount_min_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.credit_limit_amount >= parse_brazilian_amount(@credit_amount_min_filter, blank: 0) } if @credit_amount_min_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.potential_amount >= parse_brazilian_amount(@potential_amount_min_filter, blank: 0) } if @potential_amount_min_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.remaining_amount <= parse_brazilian_amount(@remaining_amount_max_filter, blank: 0) } if @remaining_amount_max_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.monthly_required_amount <= parse_brazilian_amount(@monthly_amount_max_filter, blank: 0) } if @monthly_amount_max_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.due_date.present? && goal.due_date <= due_until_date } if due_until_date.present?
    filtered_goals = filtered_goals.select { |goal| goal.status == @status_filter } if @status_filter.present?
    filtered_goals = filtered_goals.select { |goal| goal.priority == @priority_filter } if @priority_filter.present?
    filtered_goals
  end
end
