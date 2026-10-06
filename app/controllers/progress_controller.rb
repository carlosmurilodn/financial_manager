class ProgressController < ApplicationController
  def index
    entries = current_user.weight_entries.recent
    @latest_weight_entry = entries.first
    @initial_weight_entry = entries.reorder(measured_on: :asc).first
    @total_pages = [ (entries.count / 10.0).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @weight_entries = entries.offset((@current_page - 1) * 10).limit(10)
    @week_start = Health::WeeklyPlan.week_start(params[:week])
    @weekly_health_plan = Health::WeeklyPlan.build(user: current_user, week_start: @week_start)
  end
end
