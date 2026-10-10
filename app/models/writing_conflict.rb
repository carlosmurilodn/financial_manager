class WritingConflict < ApplicationRecord
  has_many :writing_timeline_links, dependent: :destroy
  has_many :writing_narrative_associations, dependent: :destroy
  has_many :writing_note_links, dependent: :destroy
  LABEL = "Conflitos"
  SINGULAR_LABEL = "Conflito"
  NAME_FIELD = :title
  FIELDS = { title: "Título", description: "Descrição", kind: "Tipo", origin: "Origem", intensity: "Intensidade", status: "Situação", consequences: "Consequências", planned_resolution: "Resolução prevista" }.freeze
  OPTIONS = { kind: { "internal" => "Interno", "interpersonal" => "Interpessoal", "social" => "Social", "institutional" => "Institucional", "environmental" => "Ambiental", "supernatural" => "Sobrenatural", "other" => "Outro" }, intensity: { "low" => "Baixa", "moderate" => "Moderada", "high" => "Alta", "critical" => "Crítica" }, status: { "planned" => "Planejado", "active" => "Ativo", "intensified" => "Intensificado", "resolved" => "Resolvido", "abandoned" => "Abandonado" } }.freeze
  include WritingNarrativeRecord
  validates :kind, inclusion: { in: OPTIONS[:kind].keys }, allow_blank: true
  validates :intensity, inclusion: { in: OPTIONS[:intensity].keys }, allow_blank: true
  validates :status, inclusion: { in: OPTIONS[:status].keys }, allow_blank: true
  has_many :writing_conflict_characters, dependent: :destroy
  has_many :writing_characters, through: :writing_conflict_characters
  has_many :writing_conflict_plots, dependent: :destroy
  has_many :writing_plots, through: :writing_conflict_plots
end
