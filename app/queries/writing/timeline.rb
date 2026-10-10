module Writing
  class Timeline
    def initialize(book, events)
      @book = book
      @events = events
    end

    def groups(order)
      return narrative_groups if order == "narrative"

      dated, undated = @events.partition { |event| event.date_mode == "exact" && event.occurred_on.present? }
      {
        "Cronologia" => dated.sort_by { |event| [ event.occurred_on, event.occurred_at&.seconds_since_midnight || 0, *manual_key(event) ] },
        "Cronologia indefinida" => undated.sort_by { |event| manual_key(event) }
      }
    end

    private

    def manual_key(event)
      [ event.position, event.created_at, event.id ]
    end

    def narrative_groups
      chapters = @book.writing_chapters.ordered.pluck(:id).each_with_index.to_h
      scenes = @book.writing_scenes.ordered.pluck(:id, :writing_chapter_id)
      scene_order = scenes.group_by(&:last).flat_map { |_chapter, items| items.each_with_index.map { |(id, chapter), index| [ id, [ chapters.fetch(chapter), index + 1 ] ] } }.to_h
      positions = @events.to_h do |event|
        appearances = event.writing_timeline_links.filter_map do |link|
          if link.writing_scene_id
            scene_order[link.writing_scene_id]
          elsif link.writing_chapter_id
            [ chapters.fetch(link.writing_chapter_id), 0 ]
          end
        end
        [ event.id, appearances.min ]
      end
      linked, unlinked = @events.partition { |event| positions[event.id].present? }
      {
        "Ordem de apresentação narrativa" => linked.sort_by { |event| [ *positions[event.id], *manual_key(event) ] },
        "Sem vínculo com o manuscrito" => unlinked.sort_by { |event| manual_key(event) }
      }
    end
  end
end
