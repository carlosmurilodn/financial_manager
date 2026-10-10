class WritingUniverseRule < ApplicationRecord
  LABEL = "Regras do Universo"
  SINGULAR_LABEL = "Regra do universo"
  NAME_FIELD = :title
  FIELDS = { title: "Título", category: "Categoria", description: "Descrição", limitations: "Limitações", exceptions: "Exceções", narrative_consequences: "Consequências narrativas", notes: "Observações" }.freeze
  OPTIONS = {}.freeze
  include WritingNarrativeRecord
end
