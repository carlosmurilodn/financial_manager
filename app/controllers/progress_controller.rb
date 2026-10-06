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
    @weekly_health_review = current_user.weekly_health_reviews.find_by(week_start: @week_start)
    weekly_weights = current_user.weight_entries.where(measured_on: @week_start..(@week_start + 6.days))
    @weekly_weight_count = weekly_weights.count
    @weekly_average_weight = weekly_weights.average(:weight_kg)
    wins = current_user.health_wins.where(achieved_on: @week_start..(@week_start + 6.days)).recent
    @weekly_wins_count = wins.count
    @wins_total_pages = [ (@weekly_wins_count / 10.0).ceil, 1 ].max
    @wins_current_page = params[:wins_page].to_i.clamp(1, @wins_total_pages)
    @health_wins = wins.offset((@wins_current_page - 1) * 10).limit(10)
  end
end
