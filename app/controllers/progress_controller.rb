class ProgressController < ApplicationController
  def index
    @health_weight_goal = current_user.health_weight_goal
    entries = current_user.weight_entries.recent
    @latest_weight_entry = entries.first
    @initial_weight_entry = entries.reorder(measured_on: :asc).first
    @weight_entries = entries
    @weight_period = %w[30 90 all].include?(params[:weight_period]) ? params[:weight_period] : "30"
    chart_entries = current_user.weight_entries.where("measured_on <= ?", Date.current)
    chart_entries = chart_entries.where(measured_on: (Date.current - (@weight_period.to_i - 1).days)..Date.current) unless @weight_period == "all"
    @weight_chart_points = chart_entries.order(:measured_on).pluck(:measured_on, :weight_kg).map { |date, weight| { date: date.iso8601, weight: weight.to_f } }
    @week_start = Health::WeeklyPlan.week_start(params[:week])
    @weekly_health_plan = Health::WeeklyPlan.build(user: current_user, week_start: @week_start)
    @weekly_health_review = current_user.weekly_health_reviews.find_by(week_start: @week_start)
    @weekly_wellbeing = current_user.weekly_wellbeings.find_by(week_start: @week_start)
    weekly_weights = current_user.weight_entries.where(measured_on: @week_start..(@week_start + 6.days))
    @weekly_weight_count = weekly_weights.count
    @weekly_average_weight = weekly_weights.average(:weight_kg)
    wins = current_user.health_wins.where(achieved_on: @week_start..(@week_start + 6.days)).recent
    @weekly_wins_count = wins.count
    @wins_total_pages = [ (@weekly_wins_count / 10.0).ceil, 1 ].max
    @wins_current_page = params[:wins_page].to_i.clamp(1, @wins_total_pages)
    @health_wins = wins.offset((@wins_current_page - 1) * 10).limit(10)
    @weekly_comparison_rows = Health::WeeklyComparisonQuery.new(
      user: current_user,
      week_start: @week_start,
      current: {
        average_weight: @weekly_average_weight,
        weight_count: @weekly_weight_count,
        goals: @weekly_health_plan.persisted? ? @weekly_health_plan.weekly_health_goals.to_a : [],
        wellbeing: @weekly_wellbeing,
        wins_count: @weekly_wins_count
      }
    ).call
  end
end
