class WeeklyWellbeingsController < ApplicationController
  before_action :set_week_start, only: %i[edit update destroy]
  before_action :load_week_options, only: %i[new create edit update]

  def index
    load_weekly_wellbeings
  end

  def new
    @selected_week_number = current_week_number
    @week_start = week_start_for_number(@selected_week_number)
    @weekly_wellbeing = current_user.weekly_wellbeings.find_or_initialize_by(week_start: @week_start)
  end

  def create
    @selected_week_number = selected_week_number
    @week_start = week_start_for_number(@selected_week_number)
    @weekly_wellbeing = current_user.weekly_wellbeings.find_or_initialize_by(week_start: @week_start)
    @weekly_wellbeing.assign_attributes(weekly_wellbeing_params)

    if @weekly_wellbeing.save
      redirect_to weekly_wellbeings_path, notice: "Bem-estar da semana salvo com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @weekly_wellbeing = current_user.weekly_wellbeings.find_or_initialize_by(week_start: @week_start)
    @selected_week_number = week_number_for(@weekly_wellbeing.week_start)
  end

  def update
    saved = current_user.with_lock do
      @weekly_wellbeing = current_user.weekly_wellbeings.find_or_initialize_by(week_start: @week_start)
      @selected_week_number = selected_week_number
      @weekly_wellbeing.week_start = week_start_for_number(@selected_week_number)
      @weekly_wellbeing.assign_attributes(weekly_wellbeing_params)
      @weekly_wellbeing.save
    end
    if saved
      redirect_to weekly_wellbeings_path, notice: "Bem-estar da semana salvo com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @weekly_wellbeing.errors.add(:week_start, "já possui um registro. Edite a semana existente ou escolha outra semana.")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    weekly_wellbeing = current_user.weekly_wellbeings.find_by!(week_start: @week_start)
    weekly_wellbeing.destroy!

    redirect_to weekly_wellbeings_path, notice: "Registro de bem-estar excluído com sucesso!", status: :see_other
  end

  def clear_filters
    session.delete(:weekly_wellbeings_week_from)
    session.delete(:weekly_wellbeings_week_to)

    redirect_to weekly_wellbeings_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def load_weekly_wellbeings
    session[:weekly_wellbeings_week_from] = params[:week_from].to_s.strip if params.key?(:week_from)
    session[:weekly_wellbeings_week_to] = params[:week_to].to_s.strip if params.key?(:week_to)

    @week_from_filter = session[:weekly_wellbeings_week_from].presence
    @week_to_filter = session[:weekly_wellbeings_week_to].presence

    wellbeings = current_user.weekly_wellbeings.order(week_start: :desc)
    wellbeings = wellbeings.where(week_start: week_from..) if week_from
    wellbeings = wellbeings.where(week_start: ..week_to) if week_to

    @latest_weekly_wellbeing = current_user.weekly_wellbeings.order(week_start: :desc).first
    @filtered_count = wellbeings.count
    @weekly_wellbeings = paginate_collection(wellbeings.to_a, per_page: pagination_per_page(:weekly_wellbeings_per_page))
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

  def weekly_wellbeing_params
    params.require(:weekly_wellbeing).permit(*WeeklyWellbeing::METRICS.keys, :notes)
  end
end
