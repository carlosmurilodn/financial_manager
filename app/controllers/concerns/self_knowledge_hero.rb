module SelfKnowledgeHero
  extend ActiveSupport::Concern

  private

  def load_self_knowledge_hero
    @today = current_user.health_journal_entries.find_by(entry_date: Date.current)
    @this_week = current_user.health_weekly_reflections.find_by(week_start: Date.current.beginning_of_week)
  end
end
