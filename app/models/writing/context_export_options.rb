module Writing
  class ContextExportOptions
    include ActiveModel::Model

    GROUPS = {
      "manuscript" => "Manuscrito: capítulos e cenas",
      "characters" => "Personagens e relacionamentos",
      "narrative" => "Tramas e conflitos",
      "universe" => "Universo: locais, organizações e regras",
      "timeline" => "Linha do tempo narrativa",
      "notes" => "Notas e ideias",
      "dossier" => "Dossiê e informações gerais do livro"
    }.freeze

    attr_accessor :groups
    validate :known_groups

    def initialize(attributes = {})
      super({ groups: GROUPS.keys }.merge(attributes))
      self.groups = Array(groups).reject(&:blank?).map(&:to_s).uniq
    end

    def include?(group)
      groups.include?(group.to_s)
    end

    def attributes
      { "groups" => groups }
    end

    private

    def known_groups
      errors.add(:base, "Selecione ao menos um grupo de conteúdo.") if groups.empty?
      errors.add(:base, "Seleção contém grupos inválidos.") if (groups - GROUPS.keys).any?
    end
  end
end
