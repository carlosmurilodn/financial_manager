class SelfKnowledgeController < ApplicationController
  def index
    redirect_to self_knowledge_evolution_path
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
    @hero_kpis = [[:mood, "Humor Médio", "sentiment_satisfied"], [:energy, "Energia Média", "bolt"], [:tension, "Tensão Média", "psychology"]].map do |field, label, icon|
      { field: field, label: label, value: @evolution.averages.fetch(field)[:mean], scale: true, icon: icon }
    end
  end
end
