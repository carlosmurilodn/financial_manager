class HealthWinsController < ApplicationController
  before_action :set_health_win, only: %i[edit update destroy]
  before_action :set_return_week, only: %i[new create edit update destroy]

  def index
    load_health_wins
  end

  def new
    @health_win = current_user.health_wins.new(achieved_on: [ Date.current, @return_week + 6.days ].min)
  end

  def create
    @health_win = current_user.health_wins.new(health_win_params)
    persist_health_win(:new, "Vitória registrada com sucesso!")
  end

  def edit
  end

  def update
    @health_win.assign_attributes(health_win_params)
    persist_health_win(:edit, "Vitória atualizada com sucesso!")
  end

  def destroy
    @health_win.destroy!
    redirect_to health_wins_path, notice: "Vitória excluída com sucesso!", status: :see_other
  end

  def clear_filters
    session.delete(:health_wins_date_from)
    session.delete(:health_wins_date_to)

    redirect_to health_wins_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def load_health_wins
    session[:health_wins_date_from] = params[:date_from].to_s.strip if params.key?(:date_from)
    session[:health_wins_date_to] = params[:date_to].to_s.strip if params.key?(:date_to)

    @date_from_filter = session[:health_wins_date_from].presence
    @date_to_filter = session[:health_wins_date_to].presence

    wins = current_user.health_wins.recent
    wins = wins.where(achieved_on: date_from..) if date_from
    wins = wins.where(achieved_on: ..date_to) if date_to

    @latest_health_win = current_user.health_wins.recent.first
    @filtered_count = wins.count
    @health_wins = paginate_collection(wins.to_a, per_page: pagination_per_page(:health_wins_per_page))
    @date_from_label = date_from&.strftime("%d/%m/%Y")
  end

  def set_health_win
    @health_win = current_user.health_wins.find(params[:id])
  end

  def set_return_week
    @return_week = Health::WeeklyPlan.week_start(params[:week].presence || @health_win&.achieved_on)
  end

  def health_win_params
    permitted = params.require(:health_win).permit(:achieved_on, :description)
    permitted[:achieved_on] = parse_form_date(permitted[:achieved_on])
    permitted
  end

  def persist_health_win(template, notice)
    if @health_win.save
      redirect_to health_wins_path, notice: notice, status: :see_other
    else
      render template, status: :unprocessable_entity
    end
  end

  def date_from
    parse_filter_date(@date_from_filter)
  end

  def date_to
    parse_filter_date(@date_to_filter)
  end

  def parse_filter_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    nil
  end

  def parse_form_date(value)
    return if value.blank?

    Date.strptime(value, "%d/%m/%Y")
  rescue ArgumentError
    value
  end
end
