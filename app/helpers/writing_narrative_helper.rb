module WritingNarrativeHelper
  def writing_narrative_group(model)
    return "Notas e Ideias" if model == WritingNote

    [ WritingPlot, WritingConflict ].include?(model) ? "Tramas e Conflitos" : "Universo e Cenários"
  end

  def writing_narrative_tabs(model)
    return [ WritingNote ] if model == WritingNote

    [ WritingPlot, WritingConflict ].include?(model) ? [ WritingPlot, WritingConflict ] : [ WritingLocation, WritingOrganization, WritingUniverseRule ]
  end

  def writing_narrative_relations(record)
    case record
    when WritingPlot
      { "Trama superior" => [ record.parent_plot ].compact, "Subtramas" => record.children.order(:title), "Personagens envolvidos" => record.writing_characters.order(:name), "Conflitos" => record.writing_conflicts.order(:title) }
    when WritingConflict
      { "Personagens envolvidos" => record.writing_characters.order(:name), "Tramas relacionadas" => record.writing_plots.order(:title) }
    when WritingLocation
      { "Local superior" => [ record.parent_location ].compact, "Locais internos" => record.children.order(:name), "Organizações" => record.writing_organizations.order(:name) }
    when WritingOrganization
      { "Local associado" => [ record.writing_location ].compact }
    when WritingCharacter
      { "Tramas" => record.writing_plots.order(:title), "Conflitos" => record.writing_conflicts.order(:title), "Organizações" => record.writing_organizations.order(:name) }
    when WritingNote
      links = record.writing_note_links.includes(*WritingNoteLink::TARGETS).to_a
      WritingNoteLink::TARGETS.to_h do |association|
        records = links.filter_map { |link| link.public_send(association) }
        [ { writing_character: "Personagens", writing_plot: "Tramas", writing_conflict: "Conflitos", writing_chapter: "Capítulos", writing_scene: "Cenas" }.fetch(association), records ]
      end
    else
      {}
    end
  end
end
