class HealthWeightGoalsController < ApplicationController
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
      redirect_to progress_path, notice: "Objetivo de peso salvo com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def health_weight_goal_params
    attributes = params.require(:health_weight_goal).permit(:target_weight, :milestones_text)
    attributes[:target_weight] = attributes[:target_weight].to_s.strip.tr(",", ".") if attributes.key?(:target_weight)
    attributes
  end
end
