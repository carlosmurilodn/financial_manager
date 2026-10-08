require "rails_helper"

RSpec.describe "Consultas de Autoconhecimento" do
  let(:user) { create(:user) }

  it "ignora métricas ausentes e mantém todos os dias empatados" do
    create(:health_journal_entry, user: user, mood: 4, tension: 3)
    create(:health_journal_entry, user: user, entry_date: Date.new(2026, 10, 8), mood: 4)
    create(:health_journal_entry, user: user, entry_date: Date.new(2026, 10, 9), energy: 5)
    create(:health_journal_entry, mood: 1)
    summary = Health::SelfKnowledgeWeek.new(user, Date.new(2026, 10, 5))
    expect(summary.averages[:mood]).to eq({ count: 2, mean: 4.0 })
    expect(summary.averages[:energy]).to eq({ count: 1, mean: 5.0 })
    expect(summary.extreme_days(:mood, :max).size).to eq(2)
  end

  it "conta somente necessidades explícitas e separa métricas legadas" do
    create(:health_journal_entry, user: user, entry_date: Date.current, mood: 2, needs: ["Descanso"], notes: "Apoio no texto")
    create(:health_weekly_reflection, user: user, week_start: Date.current.beginning_of_week, weekly_needs: ["Descanso"], next_small_step: "Meu passo")
    create(:legacy_health_review, user: user, week_start: Date.current.beginning_of_week, mood: 5, energy: 5)
    evolution = Health::SelfKnowledgeEvolution.new(user, "30")
    expect(evolution.averages[:mood][:mean]).to eq(2.0)
    expect(evolution.needs).to eq([["Descanso", 2]])
    expect(evolution.legacy_weeks.size).to eq(1)
    expect(evolution.steps.first.next_small_step).to eq("Meu passo")
  end
end
