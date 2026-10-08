class WeeklyWellbeingsController < ApplicationController
  def index
    redirect_to self_knowledge_evolution_path
  end

  def new
    redirect_to new_health_weekly_reflection_path
  end

  def edit
    date = Date.iso8601(params[:week_start]).beginning_of_week
    record = current_user.health_weekly_reflections.find_by(week_start: date)
    redirect_to record ? edit_health_weekly_reflection_path(record) : new_health_weekly_reflection_path(date: date.iso8601)
  rescue ArgumentError, TypeError
    raise ActiveRecord::RecordNotFound
  end

  def create
    redirect_to self_knowledge_evolution_path, notice: "Registros anteriores estão no histórico. Utilize os novos formulários de Autoconhecimento.", status: :see_other
  end

  alias_method :update, :create
  alias_method :destroy, :create
  alias_method :clear_filters, :index
end
