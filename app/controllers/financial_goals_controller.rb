class FinancialGoalsController < ApplicationController
  before_action :set_financial_goal, only: %i[edit update destroy]

  def index
    load_financial_goals
  end

  def new
    @financial_goal = FinancialGoal.new
  end

  def create
    @financial_goal = FinancialGoal.new(financial_goal_params)

    if @financial_goal.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "modal",
            "<turbo-stream action='visit' target='_top' url='#{financial_goals_path}'></turbo-stream>".html_safe
          )
        end

        format.html { redirect_to financial_goals_path, notice: "Objetivo criado com sucesso!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @financial_goal.update(financial_goal_params)
      redirect_to financial_goals_path, notice: "Objetivo atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @financial_goal.destroy
    load_financial_goals

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to financial_goals_path, notice: "Objetivo removido com sucesso!" }
    end
  end

  private

  def load_financial_goals
    goals = FinancialGoal.all.to_a

    @financial_goals_count = goals.size
    @financial_goals_active_count = goals.count { |goal| goal.status_planned? || goal.status_in_progress? }
    @financial_goals_target_total = goals.sum { |goal| goal.target_amount.to_d }
    @financial_goals_current_total = goals.sum { |goal| goal.current_amount.to_d }
    @financial_goals_nearest_due_date = goals.reject(&:status_completed?).map(&:due_date).compact.min

    goals = sort_collection(goals, sort_map: financial_goal_sort_map, default_sort: "due_date")
    @financial_goals = paginate_collection(goals, per_page: pagination_per_page(:financial_goals_per_page))
  end

  def financial_goal_sort_map
    {
      "description" => ->(goal) { goal.description.to_s },
      "target_amount" => ->(goal) { goal.target_amount.to_d },
      "current_amount" => ->(goal) { goal.current_amount.to_d },
      "progress" => ->(goal) { goal.progress_percent },
      "due_date" => ->(goal) { goal.due_date },
      "status" => ->(goal) { goal.status_label },
      "priority" => ->(goal) { goal.priority_before_type_cast.to_i }
    }
  end

  def set_financial_goal
    @financial_goal = FinancialGoal.find(params[:id])
  end

  def financial_goal_params
    permitted = params.require(:financial_goal).permit(
      :description,
      :target_amount,
      :current_amount,
      :due_date,
      :status,
      :priority,
      :notes
    )

    permitted[:target_amount] = parse_brazilian_amount(permitted[:target_amount])
    permitted[:current_amount] = parse_brazilian_amount(permitted[:current_amount], blank: 0)
    permitted
  end
end
