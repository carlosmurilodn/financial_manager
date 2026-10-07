class DailyCalorieEntriesController < ApplicationController
  def show
    date = Date.iso8601(params[:occurred_on].to_s)
    @entry = current_user.daily_calorie_entries.find_by(occurred_on: date) || current_user.daily_calorie_entries.new(occurred_on: date)
  rescue ArgumentError
    redirect_to weekly_health_plans_path, alert: "Data inválida.", status: :see_other
  end

  def create
    attributes = params.require(:daily_calorie_entry).permit(:occurred_on, :consumed_calories)
    @entry = Health::SaveDailyCalories.new(
      user: current_user,
      occurred_on: attributes[:occurred_on],
      consumed_calories: attributes[:consumed_calories]
    ).call

    if turbo_frame_request?
      redirect_to daily_calorie_entry_path(@entry.occurred_on.iso8601), status: :see_other
    else
      redirect_to weekly_health_plan_path(@entry.occurred_on.beginning_of_week(:monday).iso8601, anchor: "calories-#{@entry.occurred_on.beginning_of_week(:monday).iso8601}"), notice: "Calorias salvas com sucesso!", status: :see_other
    end
  rescue ActiveRecord::RecordInvalid => error
    @entry = error.record
    render :show, status: :unprocessable_entity
  rescue ArgumentError
    redirect_to weekly_health_plans_path, alert: "Data inválida.", status: :see_other
  end
end
