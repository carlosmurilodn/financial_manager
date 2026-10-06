class WeeklyWellbeingsController < ApplicationController
  before_action :set_week_start

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
      redirect_to progress_path(week: @week_start.iso8601), notice: "Bem-estar da semana salvo com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_week_start
    @week_start = Health::WeeklyPlan.week_start(params[:week_start])
  end

  def weekly_wellbeing_params
    params.require(:weekly_wellbeing).permit(*WeeklyWellbeing::METRICS.keys, :notes)
  end
end
