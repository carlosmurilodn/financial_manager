module Writing
  class ProductivityReport
    PERIODS = { "7" => "Últimos 7 Dias", "30" => "Últimos 30 Dias", "90" => "Últimos 90 Dias", "all" => "Todo O Histórico" }.freeze
    attr_reader :events, :days, :points, :added, :removed, :active_days, :average, :current_streak, :longest_streak, :chapter_rows

    def initialize(book, period:, chapter_id: nil, zone: Time.zone)
      @book = book
      @zone = zone
      all = book.writing_activity_events.order(:occurred_at, :id).to_a
      selected = chapter_id ? all.select { |event| event.chapter_id == chapter_id } : all
      today = zone.today
      first_date = book.writing_history_started_at&.in_time_zone(zone)&.to_date || today
      start_date = period == "all" ? first_date : today - period.to_i + 1
      @events = selected.select { |event| date(event) >= start_date && date(event) <= today }
      @days = events.group_by { |event| date(event) }.sort.reverse
      textual = events.select(&:textual?)
      @added = textual.sum(&:added_words)
      @removed = textual.sum(&:removed_words)
      @active_days = textual.map { |event| date(event) }.uniq.size
      @average = active_days.zero? ? 0 : (added.to_f / active_days).round
      activity_dates = selected.select(&:textual?).map { |event| date(event) }.uniq.sort
      @current_streak, @longest_streak = streaks(activity_dates, today)
      @points = evolution(selected, [ start_date, first_date ].max, today, chapter_id)
      current = ManuscriptStatistics.new(book).chapters
      deleted = all.group_by(&:chapter_id).except(*current.pluck(:id)).map do |id, history|
        { id: id, title: history.last.chapter_title, words: 0, deleted: true }
      end
      current.concat(deleted)
      @chapter_rows = current.map do |chapter|
        history = all.select { |event| event.chapter_id == chapter[:id] && event.textual? }
        filtered = history.select { |event| date(event) >= start_date && date(event) <= today }
        chapter.merge(added: filtered.sum(&:added_words), removed: filtered.sum(&:removed_words),
          active_days: filtered.map { |event| date(event) }.uniq.size, last_activity: history.last&.occurred_at)
      end
      @chapter_rows.select! { |chapter| chapter[:id] == chapter_id } if chapter_id
    end

    private

    def date(event)
      event.occurred_at.in_time_zone(@zone).to_date
    end

    def evolution(events, start_date, today, chapter_id)
      return [] unless @book.writing_history_started_at

      initial = if chapter_id
        @book.writing_history_initial_chapters.fetch(chapter_id.to_s, events.first&.previous_words.to_i)
      else
        @book.writing_history_initial_words.to_i
      end
      groups = events.group_by { |event| date(event) }
      previous = events.select { |event| date(event) < start_date }.last
      total = previous ? value(previous, chapter_id) : initial
      (start_date..today).map do |day|
        total = value(groups[day].last, chapter_id) if groups[day]&.any?
        { date: day.iso8601, words: total }
      end
    end

    def value(event, chapter_id)
      chapter_id ? event.current_words : event.book_words
    end

    def streaks(dates, today)
      longest = 0
      run = 0
      previous = nil
      dates.each do |day|
        run = previous == day - 1 ? run + 1 : 1
        longest = [ longest, run ].max
        previous = day
      end
      current = dates.last && dates.last >= today - 1 ? run : 0
      [ current, longest ]
    end
  end
end
