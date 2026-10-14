require "json"

module Health
  class JournalMarkdownExport
    def initialize(entry)
      @entry = entry
    end

    def path
      @entry.entry_date.strftime("%Y/%m/%Y-%m-%d.md")
    end

    def content
      sections = ["# Acompanhamento Diário · #{@entry.entry_date.strftime('%d/%m/%Y')}", "## Indicadores"]
      SelfKnowledgeContent::METRICS.each do |field, (label, _, descriptions)|
        value = @entry.public_send(field)
        sections << "- #{label}: #{value ? "#{value}/5 — #{descriptions.fetch(value - 1)}" : 'Não informado'}"
      end
      SelfKnowledgeContent::DAILY.each do |field, (question, *)|
        sections << section(question, @entry.public_send(field))
      end
      sections << section("Do que eu precisei", @entry.needs.join(", "))
      sections << section("Sobre minhas necessidades", @entry.needs_notes)
      sections << section(@entry.reflection_prompt.first, @entry.reflection_answer)
      sections << section("Meu espaço livre", @entry.notes)
      if @entry.legacy_content.present?
        sections << "## Dados importados do formato anterior\n\n```json\n#{JSON.pretty_generate(@entry.legacy_content)}\n```"
      end
      sections.compact.join("\n\n") + "\n"
    end

    private

    def section(title, value)
      "## #{title}\n\n#{value.to_s.strip}" if value.present?
    end
  end
end
