class WeeklyWellbeingsController < ApplicationController
  before_action :set_week_start, only: %i[edit update]

  def index
    load_weekly_wellbeings
  end

  def edit
    @weekly_wellbeing = current_user.weekly_wellbeings.find_or_initialize_by(week_start: @week_start)
  end

  def update
    saved = current_user.with_lock do
      @weekly_wellbeing = current_user.weekly_wellbeings.find_or_initialize_by(week_start: @week_start)
      @weekly_wellbeing.assign_attributes(weekly_wellbeing_params)
      @weekly_wellbeing.save
    end
    if saved
      redirect_to weekly_wellbeings_path, notice: "Bem-estar da semana salvo com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
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
