class HealthWeightGoalsController < ApplicationController
  before_action :set_health_weight_goal, only: %i[edit update destroy]

  def index
    load_health_weight_goals
  end

  def clear_filters
    session.delete(:health_weight_goals_status)
    session.delete(:health_weight_goals_goal_type)

    redirect_to health_weight_goals_path, notice: "Filtros limpos com sucesso!"
  end

  def new
    @health_weight_goal = current_user.health_weight_goals.new(goal_type: "intermediate")
  end

  def edit
  end

  def create
    @health_weight_goal = current_user.health_weight_goals.new(health_weight_goal_params)
    @health_weight_goal.position = next_position if @health_weight_goal.position.to_i.zero?

    if @health_weight_goal.save
      redirect_to health_weight_goals_path, notice: "Meta de peso criada com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @health_weight_goal.update(health_weight_goal_params)
      redirect_to health_weight_goals_path, notice: "Meta de peso atualizada com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_weight_goal.destroy!
    redirect_to health_weight_goals_path, notice: "Meta de peso excluída com sucesso!", status: :see_other
  end

  private

  def load_health_weight_goals
    @latest_weight_entry = current_user.weight_entries.recent.first
    @initial_weight_entry = current_user.weight_entries.order(:measured_on).first
    @final_health_weight_goal = current_user.health_weight_goals.final_goal.first

    session[:health_weight_goals_status] = params[:status].to_s if params.key?(:status)
    session[:health_weight_goals_goal_type] = params[:goal_type].to_s if params.key?(:goal_type)

    @status_filter = session[:health_weight_goals_status].to_s
    @goal_type_filter = session[:health_weight_goals_goal_type].to_s

    goals = current_user.health_weight_goals.ordered.to_a
    goals = goals.select { |goal| goal.goal_type == @goal_type_filter } if HealthWeightGoal::GOAL_TYPES.include?(@goal_type_filter)
    goals = goals.select { |goal| goal_reached?(goal) } if @status_filter == "done"
    goals = goals.reject { |goal| goal_reached?(goal) } if @status_filter == "pending"

    @filtered_count = goals.size
    @health_weight_goals = paginate_collection(goals, per_page: pagination_per_page(:health_weight_goals_per_page))
  end

  def set_health_weight_goal
    @health_weight_goal = current_user.health_weight_goals.find(params[:id])
  end

  def health_weight_goal_params
    attributes = params.require(:health_weight_goal).permit(:target_weight, :goal_type, :position)
    attributes[:target_weight] = attributes[:target_weight].to_s.strip.tr(",", ".") if attributes.key?(:target_weight)
    attributes
  end

  def goal_reached?(goal)
    goal.reached_by?(@latest_weight_entry)
  end

  def next_position
    current_user.health_weight_goals.maximum(:position).to_i + 1
  end
end
