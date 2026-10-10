class WritingNote < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[title description category status]

  LABEL = "Notas e Ideias"
  SINGULAR_LABEL = "Nota"
  NAME_FIELD = :title
  FIELDS = { title: "Título", description: "Conteúdo", category: "Categoria", status: "Situação" }.freeze
  OPTIONS = {
    category: { "idea" => "Ideia", "research" => "Pesquisa", "reference" => "Referência", "decision" => "Decisão narrativa", "reminder" => "Lembrete", "other" => "Outro" },
    status: { "pending" => "Pendente", "used" => "Aproveitada", "archived" => "Arquivada" }
  }.freeze
  include WritingNarrativeRecord
  validates :category, inclusion: { in: OPTIONS[:category].keys }, allow_blank: true
  validates :status, inclusion: { in: OPTIONS[:status].keys }, allow_blank: true
  has_many :writing_note_links, dependent: :destroy
end
