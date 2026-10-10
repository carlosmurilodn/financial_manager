require "zip"

module Writing
  class ContextExport
    class Error < StandardError; end

    CATALOG = {
      writing_chapter: [ :writing_chapters, "manuscript", :title, "capitulo" ],
      writing_scene: [ :writing_scenes, "manuscript", :title, "cena" ],
      writing_character: [ :writing_characters, "characters", :name, "personagem" ],
      writing_plot: [ :writing_plots, "narrative", :title, "trama" ],
      writing_conflict: [ :writing_conflicts, "narrative", :title, "conflito" ],
      writing_location: [ :writing_locations, "universe", :name, "local" ],
      writing_organization: [ :writing_organizations, "universe", :name, "organizacao" ],
      writing_universe_rule: [ :writing_universe_rules, "universe", :title, "regra" ],
      writing_timeline_event: [ :writing_timeline_events, "timeline", :title, "evento" ],
      writing_note: [ :writing_notes, "notes", :title, "nota" ]
    }.freeze
    CHARACTER_SECTIONS = {
      "Identificação" => { name: "Nome", surname: "Sobrenome", nicknames: "Apelidos", role: "Papel narrativo", status: "Situação" },
      "Características físicas" => WritingCharacter::PROFILE_SECTIONS.fetch("Características físicas"),
      "Personalidade" => { personality: "Personalidade", virtues: "Virtudes", flaws: "Defeitos", beliefs: "Crenças", internal_contradictions: "Contradições internas" },
      "História pessoal" => { origin: "Origem", past: "Passado", family: "Família", education: "Formação", profession: "Profissão" },
      "Motivações" => { motivations: "Motivações", goals: "Objetivos", internal_needs: "Necessidades internas" },
      "Medos, desejos e conflitos internos" => { fears: "Medos", desires: "Desejos", conflicts: "Conflitos" },
      "Desenvolvimento narrativo" => { initial_situation: "Situação inicial", planned_transformations: "Transformações previstas", planned_outcome: "Desfecho planejado" },
      "Segredos" => { secrets: "Segredos" }
    }.freeze

    def initialize(book, options, exported_at: Time.current)
      @book = book
      @options = options
      @converter = TiptapMarkdown.new
      @paths = []
      @references = {}
      @exported_at = exported_at
    end

    def generate(path)
      raise Error, @options.errors.full_messages.join(" ") unless @options.valid?

      build_catalog
      # Each chapter is written immediately; the full manuscript is never assembled in memory.
      Zip::OutputStream.open(path.to_s) do |zip|
        @zip = zip
        export_manuscript if @options.include?(:manuscript)
        export_characters if @options.include?(:characters)
        export_narrative if @options.include?(:narrative)
        export_universe if @options.include?(:universe)
        export_timeline if @options.include?(:timeline)
        export_notes if @options.include?(:notes)
        write("01-Dossie-do-Livro.md", dossier) if @options.include?(:dossier)
        write("00-LEIA-ME.md", readme)
      end
      filename = @book.title.parameterize(separator: "_")[0, 100].presence || "Livro"
      "#{filename}_ChatGPT.zip"
    rescue TiptapMarkdown::Error => error
      raise Error, error.message
    ensure
      @zip = nil
    end

    private

    def build_catalog
      CATALOG.each do |association, (collection, group, name, prefix)|
        next unless @options.include?(group) || (association == :writing_chapter && @options.include?(:dossier))

        columns = association == :writing_character ? [ :id, :name, :surname ] : [ :id, name ]
        @book.public_send(collection).select(*columns).find_each do |record|
          title = association == :writing_character ? record.full_name : record.public_send(name)
          @references[[ association, record.id ]] = "#{prefix}-#{record.id}: #{escape(title)}"
        end
      end
    end

    def escape(value)
      TiptapMarkdown.escape(value)
    end

    def reference(association, id)
      @references[[ association, id ]]
    end

    def write(path, content)
      return if content.blank?
      raise Error, "Nome de documento inválido." unless path.match?(%r{\A[\w/-]+\.md\z}) && !path.include?("..")

      @zip.put_next_entry(path)
      @zip.write(content.encode(Encoding::UTF_8) + "\n")
      @paths << path
    end

    def fields(record, labels, options = {})
      labels.filter_map do |field, label|
        value = record.public_send(field)
        next if value.blank?

        value = options.fetch(field, {}).fetch(value, value)
        "**#{label}:** #{escape(value)}"
      end.join("\n\n")
    end

    def record_heading(record, association)
      "## #{reference(association, record.id)}"
    end

    def references_section(label, references)
      values = references.compact.uniq
      return if values.empty?

      "### #{label}\n\n#{values.map { |value| "- #{value}" }.join("\n")}"
    end

    def joined(*parts)
      parts.flatten.reject(&:blank?).join("\n\n")
    end

    def export_manuscript
      index = 0
      @book.writing_chapters.ordered.pluck(:id).each_slice(5) do |ids|
        chapters = @book.writing_chapters.where(id: ids).preload(:writing_scenes).index_by(&:id)
        ids.each do |id|
          chapter = chapters.fetch(id)
          index += 1
          scenes = chapter.writing_scenes.select { |scene| scene.writing_book_id == @book.id }
            .sort_by { |scene| [ scene.position, scene.created_at, scene.id ] }
          legacy = @converter.render(chapter.content)
          scene_texts = scenes.map { |scene| @converter.render(scene.content) }
          plain_scenes = scenes.map { |scene| plain_text(scene.content) }
          plain_legacy = plain_text(chapter.content)
          duplicated = plain_legacy.present? && (plain_scenes.include?(plain_legacy) || plain_scenes.join(" ").strip == plain_legacy)
          sections = []
          sections << "## Texto do capítulo\n\n#{legacy}" if legacy.present? && !duplicated
          scenes.zip(scene_texts).each_with_index do |(scene, text), scene_index|
            next if text.blank?

            sections << "## Cena #{scene_index + 1}: #{escape(scene.title)}\n\n**Identificador:** cena-#{scene.id}\n\n#{text}"
          end
          without_text = plain_legacy.blank? && plain_scenes.all?(&:blank?)
          sections << "_Este capítulo ainda não possui texto cadastrado._" if without_text

          path = format("Manuscrito/Capitulo-%03d-ID-%d.md", index, chapter.id)
          header = "# #{escape(chapter.title)}\n\n**Identificador:** capitulo-#{chapter.id}\n\n**Ordem de leitura:** #{index}\n\n**Posição cadastrada:** #{chapter.position}"
          header += "\n\n**Situação do conteúdo:** Sem texto cadastrado" if without_text
          write(path, joined(header, sections.join("\n\n* * *\n\n")))
        end
      end
    end

    def plain_text(document)
      ManuscriptText.new([ document ]).text.gsub(/[[:space:]]+/, " ").strip
    end

    def relationships
      @relationships ||= @book.writing_relationships.order(:id).to_a
    end

    def relationship_text(relationship)
      source = reference(:writing_character, relationship.source_character_id)
      target = reference(:writing_character, relationship.target_character_id)
      return unless source && target

      joined("### relacionamento-#{relationship.id}", "**Direção cadastrada:** #{source} → #{target}",
        fields(relationship, { relation_type: "Tipo de vínculo", description: "Descrição", current_situation: "Situação atual" }, relation_type: WritingRelationship::TYPES))
    end

    def export_characters
      by_character = Hash.new { |hash, key| hash[key] = [] }
      relationships.each do |relationship|
        text = relationship_text(relationship)
        by_character[relationship.source_character_id] << text
        by_character[relationship.target_character_id] << text
      end
      @book.writing_characters.preload(:writing_plot_characters, :writing_conflict_characters, :writing_organization_memberships).find_each do |character|
        sections = CHARACTER_SECTIONS.filter_map do |label, attributes|
          values = fields(character, attributes, role: WritingCharacter::ROLES, status: WritingCharacter::STATUSES)
          "## #{label}\n\n#{values}" if values.present?
        end
        links = by_character[character.id].compact
        sections << "## Relacionamentos\n\n#{links.join("\n\n")}" if links.any?
        sections << references_section("Tramas", character.writing_plot_characters.map { |link| reference(:writing_plot, link.writing_plot_id) })
        sections << references_section("Conflitos narrativos", character.writing_conflict_characters.map { |link| reference(:writing_conflict, link.writing_conflict_id) })
        sections << references_section("Organizações", character.writing_organization_memberships.map { |link| reference(:writing_organization, link.writing_organization_id) })
        write(format("Personagens/Personagem-%03d.md", character.id), joined("# #{escape(character.full_name)}", "**Identificador:** personagem-#{character.id}", sections))
      end
      relationship_sections = relationships.filter_map { |relationship| relationship_text(relationship) }
      if relationship_sections.any?
        write("Personagens/Relacionamentos.md", joined("# Relacionamentos", "Cada registro mantém origem → destino. Vínculos no sentido inverso são apresentados separadamente; reciprocidade não é presumida pelo tipo do vínculo.", relationship_sections))
      end
    end

    def export_collection(path, title, collection, association, preload: [])
      return unless @book.public_send(collection).exists?

      # Stream individual records into one entry instead of retaining the entire collection text.
      @zip.put_next_entry(path)
      @zip.write("# #{title}\n\n")
      @paths << path
      @book.public_send(collection).preload(*preload).find_each do |record|
        body = fields(record, record.class::FIELDS, record.class::OPTIONS)
        extra = block_given? ? yield(record) : nil
        @zip.write(joined(record_heading(record, association), body, extra).encode(Encoding::UTF_8) + "\n\n")
      end
    end

    def narrative_links(record)
      record.writing_narrative_associations.filter_map do |link|
        next unless link.writing_book_id == @book.id

        reference(:writing_scene, link.writing_scene_id) || reference(:writing_chapter, link.writing_chapter_id)
      end
    end

    def export_narrative
      export_collection("Narrativa/Tramas.md", "Tramas", :writing_plots, :writing_plot,
        preload: [ :writing_plot_characters, :children, :writing_narrative_associations ]) do |plot|
        joined(references_section("Trama principal", [ reference(:writing_plot, plot.parent_plot_id) ]),
          references_section("Subtramas", plot.children.map { |child| reference(:writing_plot, child.id) }),
          references_section("Personagens", plot.writing_plot_characters.map { |link| reference(:writing_character, link.writing_character_id) }),
          references_section("Manuscrito associado", narrative_links(plot)))
      end
      export_collection("Narrativa/Conflitos.md", "Conflitos", :writing_conflicts, :writing_conflict,
        preload: [ :writing_conflict_characters, :writing_conflict_plots, :writing_narrative_associations ]) do |conflict|
        joined(references_section("Personagens", conflict.writing_conflict_characters.map { |link| reference(:writing_character, link.writing_character_id) }),
          references_section("Tramas", conflict.writing_conflict_plots.map { |link| reference(:writing_plot, link.writing_plot_id) }),
          references_section("Manuscrito associado", narrative_links(conflict)))
      end
    end

    def export_universe
      export_collection("Universo/Locais.md", "Locais", :writing_locations, :writing_location, preload: [ :children, :writing_narrative_associations ]) do |location|
        joined(references_section("Local de origem", [ reference(:writing_location, location.parent_location_id) ]),
          references_section("Sublocais", location.children.map { |child| reference(:writing_location, child.id) }),
          references_section("Manuscrito associado", narrative_links(location)))
      end
      export_collection("Universo/Organizacoes.md", "Organizações", :writing_organizations, :writing_organization,
        preload: [ :writing_organization_memberships, :writing_narrative_associations ]) do |organization|
        members = organization.writing_organization_memberships.filter_map do |membership|
          character = reference(:writing_character, membership.writing_character_id)
          joined(character, membership.role.present? ? "Papel: #{escape(membership.role)}" : nil) if character
        end
        joined(references_section("Local", [ reference(:writing_location, organization.writing_location_id) ]),
          references_section("Integrantes", members), references_section("Manuscrito associado", narrative_links(organization)))
      end
      export_collection("Universo/Regras.md", "Regras do universo", :writing_universe_rules, :writing_universe_rule)
    end

    def link_references(links, targets)
      links.flat_map do |link|
        next [] unless link.writing_book_id == @book.id

        targets.filter_map { |target| reference(target, link.public_send("#{target}_id")) }
      end
    end

    def export_timeline
      events = @book.writing_timeline_events.preload(:writing_timeline_links).to_a
      return if events.empty?

      sections = Timeline.new(@book, events).groups("chronological").filter_map do |label, records|
        next if records.empty?

        values = records.each_with_index.map do |event, index|
          joined(record_heading(event, :writing_timeline_event),
            fields(event, WritingTimelineEvent::FIELDS.merge(occurred_on: "Data exata", position: "Posição narrativa cadastrada"), WritingTimelineEvent::OPTIONS),
            event.occurred_at ? "**Horário:** #{event.occurred_at.strftime('%H:%M:%S')}" : nil,
            "**Ordem neste grupo:** #{index + 1}",
            references_section("Acontecimento de referência", [ reference(:writing_timeline_event, event.reference_event_id) ]),
            references_section("Elementos associados", link_references(event.writing_timeline_links, WritingTimelineLink::TARGETS.keys)))
        end
        joined("# #{label}", values)
      end
      write("Planejamento/Linha-do-Tempo.md", joined("# Linha do tempo", "Datas exatas são ordenadas cronologicamente. Datas aproximadas, relativas e sem definição mantêm a ordem cadastrada em grupo separado.", sections))
    end

    def export_notes
      export_collection("Planejamento/Notas-e-Ideias.md", "Notas e ideias", :writing_notes, :writing_note, preload: [ :writing_note_links ]) do |note|
        references_section("Elementos associados", link_references(note.writing_note_links, WritingNoteLink::TARGETS))
      end
    end

    def document_index(paths)
      paths.map { |path| "- [#{path}](#{path})" }.join("\n")
    end

    def dossier
      chapters = @book.writing_chapters.ordered.select(:id, :title, :position).to_a
      index = chapters.each_with_index.map do |chapter, number|
        "#{number + 1}. #{reference(:writing_chapter, chapter.id)} (posição cadastrada: #{chapter.position})"
      end.join("\n")
      joined("# Dossiê do livro", "**Identificador:** livro-#{@book.id}",
        fields(@book, { title: "Título", subtitle: "Subtítulo", author: "Autor", genre: "Gênero", synopsis: "Sinopse", premise: "Premissa", target_audience: "Público-alvo", status: "Situação", notes: "Observações", started_on: "Início", expected_completion_on: "Conclusão prevista" }, genre: WritingBook::GENRES, status: WritingBook::STATUSES),
        @book.secondary_genres.any? ? "**Gêneros secundários:** #{escape(@book.secondary_genres.map { |genre| WritingBook::GENRES.fetch(genre, genre) }.join(', '))}" : nil,
        "## Estrutura do manuscrito\n\n#{chapters.size} capítulos e #{@book.writing_scenes.count} cenas cadastrados.",
        index.present? ? "## Índice dos capítulos\n\n#{index}" : nil,
        @paths.any? ? "## Documentos exportados\n\n#{document_index(@paths)}" : nil)
    end

    def readme
      joined("# Contexto literário: #{escape(@book.title)}", @exported_at ? "**Exportado em:** #{@exported_at.in_time_zone('America/Sao_Paulo').strftime('%d/%m/%Y às %H:%M:%S %:z')}" : nil,
        "Este conteúdo é uma cópia dos dados salvos. A fonte oficial permanece no Gerenciador Pessoal. Alterações feitas nesta cópia não modificam a obra original.",
        "## Grupos selecionados\n\n#{@options.groups.map { |group| "- #{ContextExportOptions::GROUPS.fetch(group)}" }.join("\n")}",
        "## Estrutura e leitura\n\nComece pelo dossiê, quando incluído. Leia Manuscrito/ pela numeração dos arquivos, que acompanha a ordem atual dos capítulos. Todos os capítulos cadastrados são incluídos quando o manuscrito é selecionado, inclusive os sem texto, identificados com aviso explícito. As cenas seguem a ordem cadastrada dentro de cada capítulo. Personagens/, Narrativa/, Universo/ e Planejamento/ contêm os respectivos registros selecionados. Grupos sem registros não geram documentos vazios.",
        "## Identificadores e referências\n\nIdentificadores seguem tipo-ID (livro, capitulo, cena, personagem, trama, conflito, local, organizacao, regra, evento, nota e relacionamento). IDs permanecem estáveis entre exportações; a numeração de leitura pode mudar. Referências exibem ID e nome apenas dos grupos incluídos. Datas relativas e aproximadas não são convertidas em datas exatas. Relações preservam origem → destino; registros inversos permanecem separados.",
        "## Documentos incluídos\n\n#{document_index([ '00-LEIA-ME.md', *@paths ].sort)}",
        "Somente documentos Markdown UTF-8. Imagens e anexos não fazem parte deste pacote. Formatação visual sem equivalente Markdown é simplificada. Nenhum resumo interpretativo foi gerado.")
    end
  end
end
