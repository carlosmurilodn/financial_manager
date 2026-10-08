require "rails_helper"

RSpec.describe HealthJournalEntry, type: :model do
  it "permite registro parcial com uma métrica" do
    expect(build(:health_journal_entry, main_thought: nil, mood: 3)).to be_valid
  end

  it "rejeita registro vazio e somente espaços" do
    expect(build(:health_journal_entry, main_thought: " ")).not_to be_valid
  end

  it "permite somente necessidade selecionada" do
    expect(build(:health_journal_entry, main_thought: nil, needs: ["Movimento"])).to be_valid
  end

  it "rejeita escalas fora de 1 a 5 e valores fracionários" do
    [0, 6, 2.5].each do |value|
      expect(build(:health_journal_entry, mood: value)).not_to be_valid
    end
  end

  it "exige data e limita texto" do
    expect(build(:health_journal_entry, entry_date: nil)).not_to be_valid
    expect(build(:health_journal_entry, main_thought: "a" * 2001)).not_to be_valid
    expect(build(:health_journal_entry, main_thought: "a" * 2000)).to be_valid
  end

  it "impede dois diários do mesmo usuário na mesma data" do
    saved = create(:health_journal_entry)
    expect(build(:health_journal_entry, user: saved.user, entry_date: saved.entry_date)).not_to be_valid
  end

  it "seleciona pergunta estável por data e preserva identificador salvo" do
    entry = create(:health_journal_entry)
    key = entry.reflection_prompt_key
    expect(entry.reload.reflection_prompt_key).to eq(key)
    expect(build(:health_journal_entry, entry_date: entry.entry_date).reflection_prompt).to eq(entry.reflection_prompt)
    entry.update!(entry_date: entry.entry_date + 1)
    expect(entry.reflection_prompt_key).not_to eq(key)
  end

  it "remove seleção vazia e rejeita necessidades desconhecidas" do
    expect(build(:health_journal_entry, needs: ["", "Descanso", "Descanso"]).needs).to eq(["Descanso"])
    expect(build(:health_journal_entry, needs: ["Inválida"])).not_to be_valid
  end
end
