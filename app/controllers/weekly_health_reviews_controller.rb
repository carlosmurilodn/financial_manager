class WeeklyHealthReviewsController < ApplicationController
  def index
    redirect_to self_knowledge_path
  end

  def new
    redirect_to params[:review_kind] == "weekly" ? new_health_weekly_reflection_path : new_health_journal_entry_path
  end

  def show
    redirect_to destination
  end

  def edit
    redirect_to destination
  end

  def create
    redirect_to self_knowledge_path, notice: "O formato mudou. Abra Diário ou Revisão Semanal para registrar suas respostas.", status: :see_other
  end

  alias_method :update, :create
  alias_method :destroy, :create
  alias_method :clear_filters, :index

  private

  def destination
    date = Date.iso8601(params[:week_start])
    if params[:kind] == "daily"
      record = current_user.health_journal_entries.find_by(entry_date: date)
      record ? health_journal_entry_path(record) : new_health_journal_entry_path(date: date.iso8601)
    else
      start = date.beginning_of_week
      record = current_user.health_weekly_reflections.find_by(week_start: start)
      record ? health_weekly_reflection_path(record) : new_health_weekly_reflection_path(date: start.iso8601)
    end
  rescue ArgumentError, TypeError
    raise ActiveRecord::RecordNotFound
  end
end
