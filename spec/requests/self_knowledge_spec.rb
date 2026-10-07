require "rails_helper"

RSpec.describe "Autoconhecimento", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  it "mostra página inicial e três áreas" do
    get self_knowledge_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Diário", "Revisão Semanal", "Minha Evolução")
  end

  it "cria diário e reutiliza a mesma data sem duplicar" do
    attributes = { entry_date: "07/10/2026", main_thought: "Pensamento registrado", mood: "4" }
    2.times { post health_journal_entries_path, params: { health_journal_entry: attributes } }
    expect(user.health_journal_entries.count).to eq(1)
    follow_redirect!
    expect(response.body).to include("Pensamento registrado")
  end

  it "edita e exclui diário" do
    day = create(:health_journal_entry, user: user)
    patch health_journal_entry_path(day), params: { health_journal_entry: { entry_date: "07/10/2026", emotions: "Alívio" } }
    expect(day.reload.emotions).to eq("Alívio")
    delete health_journal_entry_path(day)
    expect(user.health_journal_entries.count).to eq(0)
  end

  it "preserva conteúdo após data inválida" do
    post health_journal_entries_path, params: { health_journal_entry: { entry_date: "31/02/2026", main_thought: "Não perder" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Não perder", "31/02/2026")
  end

  it "mostra dicas completas e pergunta rotativa estável" do
    get new_health_journal_entry_path(date: "2026-10-07")
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(Health::SelfKnowledgeContent::DAILY[:main_thought][1])
    get prompt_health_journal_entries_path(date: "2026-10-07")
    first = response.parsed_body
    get prompt_health_journal_entries_path(date: "2026-10-07")
    expect(response.parsed_body).to eq(first)
  end

  it "filtra histórico e não inclui registros de outro usuário" do
    create(:health_journal_entry, user: user, main_thought: "Dia selecionado")
    create(:health_journal_entry, user: user, entry_date: Date.new(2026, 9, 1), main_thought: "Dia fora")
    create(:health_journal_entry, main_thought: "Texto privado")
    get health_journal_entries_path(date_from: "2026-10-01", date_to: "2026-10-31")
    expect(response.body).to include("Dia selecionado")
    expect(response.body).not_to include("Dia fora", "Texto privado")
  end

  it "restringe leitura, edição e exclusão ao usuário" do
    foreign = create(:health_journal_entry)
    get health_journal_entry_path(foreign)
    expect(response).to have_http_status(:not_found)
    patch health_journal_entry_path(foreign), params: { health_journal_entry: { entry_date: "07/10/2026", notes: "Intrusão" } }
    expect(response).to have_http_status(:not_found)
    delete health_journal_entry_path(foreign)
    expect(response).to have_http_status(:not_found)
  end

  it "cria revisão em três etapas e salva parcialmente" do
    post health_weekly_reflections_path, params: { selected_week: "2026-10-05", continue: "1", health_weekly_reflection: { recurring_patterns: "Padrão semanal" } }
    week = user.health_weekly_reflections.first
    expect(response).to redirect_to(edit_health_weekly_reflection_path(week, step: 1))
    get edit_health_weekly_reflection_path(week)
    expect(response.body).to include("Minha semana", "Entendendo meus padrões", "Levando algo comigo")
    patch health_weekly_reflection_path(week), params: { selected_week: "2026-10-05", health_weekly_reflection: { next_small_step: "Escolher três prioridades" } }
    follow_redirect!
    expect(response.body).to include("Escolher três prioridades", "Padrão semanal")
    delete health_weekly_reflection_path(week)
    expect(user.health_weekly_reflections.count).to eq(0)
  end

  it "renderiza revisão vazia, evita duplicação e rejeita semana inválida" do
    get new_health_weekly_reflection_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Semana do lançamento")
    2.times { post health_weekly_reflections_path, params: { selected_week: "2026-10-05", health_weekly_reflection: { routine_satisfaction: "3" } } }
    expect(user.health_weekly_reflections.count).to eq(1)
    post health_weekly_reflections_path, params: { selected_week: "2026-10-06", health_weekly_reflection: { next_small_step: "Não perder" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Não perder")
  end

  it "restringe revisões e resumo semanal ao usuário" do
    week = create(:health_weekly_reflection)
    create(:health_journal_entry, user: week.user, main_thought: "Conteúdo privado")
    get health_weekly_reflection_path(week)
    expect(response).to have_http_status(:not_found)
    get self_knowledge_week_summary_path(date: "2026-10-05")
    expect(response.body).not_to include("Conteúdo privado")
  end

  it "renderiza evolução e dashboard com métricas reais" do
    create(:health_journal_entry, user: user, entry_date: Date.current, mood: 4, tension: 2, needs: ["Descanso"])
    create(:health_weekly_reflection, user: user, week_start: Date.current.beginning_of_week, next_small_step: "Dormir cedo")
    get self_knowledge_evolution_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Dormir cedo", "Descanso", "self-knowledge-chart")
    get progress_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Autoconhecimento", "Diários: 1 de 7")
  end
end
