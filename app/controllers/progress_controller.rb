class ProgressController < ApplicationController
  def index
    @health_weight_goals = current_user.health_weight_goals.ordered
    @final_health_weight_goal = @health_weight_goals.final_goal.first
    @intermediate_health_weight_goals = @health_weight_goals.intermediate
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
    @self_knowledge_week = Health::SelfKnowledgeWeek.new(current_user, @week_start)
    @self_knowledge_reflection = current_user.health_weekly_reflections.find_by(week_start: @week_start)
    @saved_weekly_goals = @weekly_health_plan.persisted? ? @weekly_health_plan.weekly_health_goals.to_a : []
    ActiveRecord::Associations::Preloader.new(records: @saved_weekly_goals, associations: :weekly_health_goal_days).call
    @completed_weekly_goals_count = @saved_weekly_goals.count { |goal| goal.completed_count >= goal.target_count }

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
        wellbeing: @self_knowledge_reflection,
        self_knowledge: @self_knowledge_week,
        wins_count: @weekly_wins_count
      }
    ).call.reject { |row| row[:kind] == :wins }
  end
end
