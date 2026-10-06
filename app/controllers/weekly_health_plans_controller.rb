class WeeklyHealthPlansController < ApplicationController
  before_action :set_week_start

  def edit
    @weekly_health_plan = Health::WeeklyPlan.build(user: current_user, week_start: @week_start)
  end

  def update
    saved = current_user.with_lock do
      @weekly_health_plan = current_user.weekly_health_plans.find_or_initialize_by(week_start: @week_start)
      @weekly_health_plan.assign_attributes(weekly_health_plan_params)
      @weekly_health_plan.save
    end

    if saved
      redirect_to progress_path(week: @week_start.iso8601), notice: "Metas da semana salvas com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_week_start
    @week_start = Health::WeeklyPlan.week_start(params[:week_start])
  end

  def weekly_health_plan_params
    params.require(:weekly_health_plan).permit(weekly_health_goals_attributes: [ :id, :name, :target_count, :completed_count, :notes, :_destroy ])
  end
end
