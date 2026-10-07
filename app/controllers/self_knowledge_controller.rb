class SelfKnowledgeController < ApplicationController
  include SelfKnowledgeHero
  before_action :load_self_knowledge_hero, only: :evolution

  def index
    redirect_to health_journal_entries_path
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
