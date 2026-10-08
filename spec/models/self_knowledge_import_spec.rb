require "rails_helper"
require Rails.root.join("db/migrate/20261007150000_create_self_knowledge_records")

RSpec.describe "Migração de Autoconhecimento" do
  it "preserva textos sem correspondência e não sobrescreve novas respostas ao repetir importação" do
    user = create(:user)
    source = create(:legacy_health_review, user: user, review_kind: "daily", week_start: Date.new(2026, 10, 7), within_control: "Controle original", minimum_goal: "Meta original", notes: "n" * 2000)
    migration = CreateSelfKnowledgeRecords.new
    migration.suppress_messages { migration.import_records }
    journal = user.health_journal_entries.first
    expect(journal.entry_date).to eq(source.week_start)
    expect(journal.legacy_content["within_control"]).to eq("Controle original")
    expect(journal.legacy_content["minimum_goal"]).to eq("Meta original")
    expect(journal.notes.length).to eq(2000)
    journal.update!(main_thought: "Novo texto")
    migration.suppress_messages { migration.import_records }
    expect(user.health_journal_entries.count).to eq(1)
    expect(journal.reload.main_thought).to eq("Novo texto")
    expect(source.reload.notes.length).to eq(2000)
  end

  it "preserva semana e métricas antigas sem inventar diário" do
    user = create(:user)
    original = create(:legacy_wellbeing, user: user)
    source = create(:legacy_health_review, user: user, mood: original.mood, energy: original.energy, routine_satisfaction: original.routine_satisfaction, notes: original.notes, legacy_wellbeing_id: original.id, minimum_goal: "Passo anterior")
    migration = CreateSelfKnowledgeRecords.new
    migration.suppress_messages { migration.import_records }
    reflection = user.health_weekly_reflections.first
    expect(reflection.week_start).to eq(source.week_start)
    expect(reflection.next_small_step).to eq("Passo anterior")
    expect(reflection.legacy_content["energy"]).to eq(4)
    expect(user.health_journal_entries).to be_empty
    expect(original.reload.notes).to eq("Observação histórica")
  end
end
