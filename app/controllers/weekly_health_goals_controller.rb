class WeeklyHealthGoalsController < ApplicationController
  def toggle_day
    occurred_on = Date.iso8601(params[:occurred_on].to_s)
    goal = nil

    current_user.with_lock do
      goal = current_user.weekly_health_goals.find(params[:id])
      day = goal.weekly_health_goal_days.find_or_initialize_by(occurred_on: occurred_on)
      day.completed = !day.completed?
      day.save!
      goal.sync_completed_count!
      Health::RecalculateDailyCalories.new(user: current_user, dates: [ occurred_on ]).call
    end

    redirect_to weekly_health_plan_path(goal.weekly_health_plan.week_start.iso8601), notice: "Meta atualizada com sucesso!", status: :see_other
  rescue ArgumentError
    redirect_to weekly_health_plans_path, alert: "Dia inválido.", status: :see_other
  end
end
