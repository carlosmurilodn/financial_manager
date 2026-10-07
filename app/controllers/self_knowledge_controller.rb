class SelfKnowledgeController < ApplicationController
  def index
    @area = "home"
    @today = current_user.health_journal_entries.find_by(entry_date: Date.current)
    @this_week = current_user.health_weekly_reflections.find_by(week_start: Date.current.beginning_of_week)
  end

  def week_summary
    date = Date.iso8601(params[:date].to_s)
    render partial: "self_knowledge/week_summary", locals: { summary: Health::SelfKnowledgeWeek.new(current_user, date) }
  rescue ArgumentError
    head :unprocessable_entity
  end

  def evolution
    @area = "evolution"
    @evolution = Health::SelfKnowledgeEvolution.new(current_user, params[:period])
  end
end
