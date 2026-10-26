class ExerciseDayCopiesController < ApplicationController
  before_action :set_exercise_entry

  def new
    @dates = [ "" ]
  end

  def create
    @dates = params.permit(dates: []).fetch(:dates, []).reject(&:blank?)
    dates = Exercises::CopyDay.new(user: current_user, source_date: @exercise_entry.performed_on, dates: @dates).call
    redirect_to health_exercises_path, notice: "Dia de exercícios copiado para #{dates.size} dia(s).", status: :see_other
  rescue ArgumentError => error
    render_copy_error(error.message)
  rescue ActiveRecord::RecordInvalid => error
    render_copy_error(error.record.errors.full_messages.join(". "))
  end

  private

  def set_exercise_entry
    @exercise_entry = current_user.exercise_entries.find(params[:health_exercise_id])
  end

  def render_copy_error(message)
    @dates = [ "" ] if @dates.blank?
    @exercise_entry.errors.add(:base, message)
    render :new, status: :unprocessable_entity
  end
end
