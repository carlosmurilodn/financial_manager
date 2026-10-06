class HealthWeightGoalsController < ApplicationController
  def show
    load_health_weight_goal
  end

  def clear_filters
    session.delete(:health_weight_goals_status)

    redirect_to health_weight_goal_path, notice: "Filtros limpos com sucesso!"
  end

  def edit
    @health_weight_goal = current_user.health_weight_goal || current_user.build_health_weight_goal
  end

  def update
    saved = current_user.with_lock do
      @health_weight_goal = current_user.health_weight_goal || current_user.build_health_weight_goal
      @health_weight_goal.assign_attributes(health_weight_goal_params)
      @health_weight_goal.save
    end

    if saved
      redirect_to health_weight_goal_path, notice: "Objetivo de peso salvo com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_health_weight_goal
    @health_weight_goal = current_user.health_weight_goal
    @latest_weight_entry = current_user.weight_entries.recent.first
    @initial_weight_entry = current_user.weight_entries.order(:measured_on).first

    session[:health_weight_goals_status] = params[:status].to_s if params.key?(:status)
    @status_filter = session[:health_weight_goals_status].to_s

    milestones = milestone_rows
    milestones = milestones.select { |milestone| milestone[:status] == @status_filter } if %w[done pending].include?(@status_filter)

    @filtered_count = milestones.size
    @milestones = paginate_collection(milestones, per_page: pagination_per_page(:health_weight_goals_per_page))
  end

  def health_weight_goal_params
    attributes = params.require(:health_weight_goal).permit(:target_weight, :milestones_text)
    attributes[:target_weight] = attributes[:target_weight].to_s.strip.tr(",", ".") if attributes.key?(:target_weight)
    attributes
  end

  def milestone_rows
    return [] unless @health_weight_goal

    weights = @health_weight_goal.ordered_milestones + [ @health_weight_goal.target_weight ]
    weights.map do |weight|
      reached = @latest_weight_entry && @latest_weight_entry.weight_kg <= weight
      {
        weight: weight,
        kind: weight == @health_weight_goal.target_weight ? "Meta final" : "Marco intermediário",
        status: reached ? "done" : "pending",
        status_label: reached ? "Cumprido" : "Pendente"
      }
    end
  end
end
