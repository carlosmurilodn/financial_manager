class WritingPlot < ApplicationRecord
  LABEL = "Tramas"
  SINGULAR_LABEL = "Trama"
  NAME_FIELD = :title
  FIELDS = { title: "Título", description: "Descrição", kind: "Tipo", status: "Situação", narrative_goal: "Objetivo narrativo", planned_development: "Desenvolvimento previsto", planned_outcome: "Desfecho planejado" }.freeze
  OPTIONS = { kind: { "main" => "Principal", "secondary" => "Secundária", "parallel" => "Paralela" }, status: { "planned" => "Planejada", "developing" => "Em desenvolvimento", "resolved" => "Resolvida", "abandoned" => "Abandonada" } }.freeze
  include WritingNarrativeRecord
  validates :kind, inclusion: { in: OPTIONS[:kind].keys }, allow_blank: true
  validates :status, inclusion: { in: OPTIONS[:status].keys }, allow_blank: true
  PARENT_ASSOCIATION = :parent_plot
  belongs_to :parent_plot, class_name: "WritingPlot", optional: true
  has_many :children, class_name: "WritingPlot", foreign_key: :parent_plot_id, dependent: :nullify
  include WritingHierarchy
  has_many :writing_plot_characters, dependent: :destroy
  has_many :writing_characters, through: :writing_plot_characters
  has_many :writing_conflict_plots, dependent: :destroy
  has_many :writing_conflicts, through: :writing_conflict_plots
end
