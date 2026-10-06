class HealthWinsController < ApplicationController
  before_action :set_health_win, only: %i[edit update destroy]
  before_action :set_return_week

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
    redirect_to progress_path(week: @return_week.iso8601), notice: "Vitória excluída com sucesso!", status: :see_other
  end

  private

  def set_health_win
    @health_win = current_user.health_wins.find(params[:id])
  end

  def set_return_week
    @return_week = Health::WeeklyPlan.week_start(params[:week].presence || @health_win&.achieved_on)
  end

  def health_win_params
    params.require(:health_win).permit(:achieved_on, :description)
  end

  def persist_health_win(template, notice)
    if @health_win.save
      week = @health_win.achieved_on.beginning_of_week(:monday)
      redirect_to progress_path(week: week.iso8601), notice: notice, status: :see_other
    else
      render template, status: :unprocessable_entity
    end
  end
end
