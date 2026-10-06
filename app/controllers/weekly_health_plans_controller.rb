class WeeklyHealthPlansController < ApplicationController
  before_action :set_week_start, only: %i[edit update destroy]
  before_action :load_week_options, only: %i[new create edit update]

  def index
    load_weekly_health_plans
  end

  def new
    @selected_week_number = current_week_number
    @week_start = week_start_for_number(@selected_week_number)
    @weekly_health_plan = Health::WeeklyPlan.build(user: current_user, week_start: @week_start)
  end

  def create
    @selected_week_number = selected_week_number
    @week_start = week_start_for_number(@selected_week_number)
    @weekly_health_plan = current_user.weekly_health_plans.find_or_initialize_by(week_start: @week_start)
    @weekly_health_plan.assign_attributes(weekly_health_plan_params)

    if @weekly_health_plan.save
      redirect_to weekly_health_plans_path, notice: "Metas da semana salvas com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @weekly_health_plan = Health::WeeklyPlan.build(user: current_user, week_start: @week_start)
    @selected_week_number = week_number_for(@weekly_health_plan.week_start)
  end

  def update
    saved = current_user.with_lock do
      @weekly_health_plan = current_user.weekly_health_plans.find_or_initialize_by(week_start: @week_start)
      @selected_week_number = selected_week_number
      @weekly_health_plan.week_start = week_start_for_number(@selected_week_number)
      @weekly_health_plan.assign_attributes(weekly_health_plan_params)
      @weekly_health_plan.save
    end

    if saved
      redirect_to weekly_health_plans_path, notice: "Metas da semana salvas com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @weekly_health_plan.errors.add(:week_start, "já possui metas cadastradas. Edite a semana existente ou escolha outra semana.")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    weekly_health_plan = current_user.weekly_health_plans.find_by!(week_start: @week_start)
    weekly_health_plan.destroy!

    redirect_to weekly_health_plans_path, notice: "Metas da semana excluídas com sucesso!", status: :see_other
  end

  def clear_filters
    session.delete(:weekly_health_plans_week_from)
    session.delete(:weekly_health_plans_week_to)

    redirect_to weekly_health_plans_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def load_weekly_health_plans
    session[:weekly_health_plans_week_from] = params[:week_from].to_s.strip if params.key?(:week_from)
    session[:weekly_health_plans_week_to] = params[:week_to].to_s.strip if params.key?(:week_to)

    @week_from_filter = session[:weekly_health_plans_week_from].presence
    @week_to_filter = session[:weekly_health_plans_week_to].presence

    plans = current_user.weekly_health_plans.includes(weekly_health_goals: :weekly_health_goal_days).order(week_start: :desc)
    plans = plans.where(week_start: week_from..) if week_from
    plans = plans.where(week_start: ..week_to) if week_to

    @latest_weekly_health_plan = current_user.weekly_health_plans.includes(:weekly_health_goals).order(week_start: :desc).first
    @filtered_count = plans.count
    @weekly_health_plans = paginate_collection(plans.to_a, per_page: pagination_per_page(:weekly_health_plans_per_page))
    @current_week_start = Health::WeeklyPlan.week_start(Date.current)
    @week_from_label = week_from&.strftime("%d/%m/%Y")
  end

  def load_week_options
    @week_options = (1..52).map do |week_number|
      week_start = week_start_for_number(week_number)
      week_end = week_start + 6.days
      [ "Semana #{week_number} - De #{week_start.strftime("%d/%m/%Y")} a #{week_end.strftime("%d/%m/%Y")}", week_number ]
    end
  end

  def selected_week_number
    week_number = params[:week_number].to_i
    week_number.between?(1, 52) ? week_number : current_week_number
  end

  def current_week_number
    [[ Date.current.cweek, 1 ].max, 52 ].min
  end

  def week_number_for(date)
    [[ date.cweek, 1 ].max, 52 ].min
  end

  def week_start_for_number(week_number)
    Date.commercial(Date.current.cwyear, week_number, 1)
  end

  def set_week_start
    @week_start = Health::WeeklyPlan.week_start(params[:week_start])
  end

  def week_from
    parse_filter_date(@week_from_filter)
  end

  def week_to
    parse_filter_date(@week_to_filter)
  end

  def parse_filter_date(value)
    return if value.blank?

    Health::WeeklyPlan.week_start(Date.iso8601(value))
  rescue ArgumentError
    nil
  end

  def weekly_health_plan_params
    params.require(:weekly_health_plan).permit(weekly_health_goals_attributes: [ :id, :name, :target_count, :completed_count, :notes, :_destroy ])
  end
end
