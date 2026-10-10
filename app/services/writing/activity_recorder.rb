module Writing
  class ActivityRecorder
    def self.track(record, operation)
      book = WritingBook.find(record.writing_book_id)
      key = "writing_activity_#{book.id}"
      return yield if Thread.current[key] || book.destroyed?

      book.with_lock do
        Thread.current[key] = true
        begin
          start_history(book)
          chapter = record.is_a?(WritingChapter) ? record : record.writing_chapter
          before = chapter_text(book, chapter.id)
          chapter_title = chapter.title
          result = yield
          after = chapter_text(book, chapter.id)
          changes = WordChanges.call(before, after)
          if before.gsub(/[[:space:]]+/, " ").strip != after.gsub(/[[:space:]]+/, " ").strip
            previous_total = book.writing_activity_events.order(id: :desc).pick(:book_words) || book.writing_history_initial_words
            book.writing_activity_events.create!(changes.merge(chapter_id: chapter.id, chapter_title: chapter_title,
              scene_id: record.is_a?(WritingScene) ? record.id : nil,
              scene_title: record.is_a?(WritingScene) ? record.title : nil,
              operation: operation, occurred_at: Time.current, book_words: previous_total + changes[:net_words]))
          end
          result
        ensure
          Thread.current[key] = nil
        end
      end
    end

    def self.start_history(book)
      return if book.writing_history_started_at

      statistics = ManuscriptStatistics.new(book)
      book.update_columns(writing_history_started_at: Time.current,
        writing_history_initial_words: statistics.totals[:words],
        writing_history_initial_chapters: statistics.chapters.to_h { |chapter| [ chapter[:id].to_s, chapter[:words] ] })
    end

    def self.move(record, destination)
      book = WritingBook.find(record.writing_book_id)
      book.with_lock do
        start_history(book)
        origin = record.writing_chapter
        chapters = [ origin, destination ]
        before = chapters.to_h { |chapter| [ chapter.id, ManuscriptText.words(chapter_text(book, chapter.id)).size ] }
        yield
        total = ManuscriptStatistics.new(book).totals[:words]
        chapters.each do |chapter|
          book.writing_activity_events.create!(chapter_id: chapter.id, chapter_title: chapter.title,
            scene_id: record.id, scene_title: record.title, operation: "move", occurred_at: Time.current,
            previous_words: before[chapter.id], current_words: ManuscriptText.words(chapter_text(book, chapter.id)).size,
            added_words: 0, removed_words: 0, net_words: 0, book_words: total)
        end
      end
    end

    def self.chapter_text(book, id)
      chapter = book.writing_chapters.find_by(id: id)
      return "" unless chapter

      documents = chapter.writing_scenes.ordered.pluck(:content)
      documents.unshift(chapter.content) unless documents.include?(chapter.content)
      ManuscriptText.new(documents).text
    end
  end
end
