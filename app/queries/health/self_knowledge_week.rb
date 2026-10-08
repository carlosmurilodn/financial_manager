module Health
  class SelfKnowledgeWeek
    attr_reader :start, :days, :averages

    def initialize(user, date)
      @start = date.beginning_of_week
      @days = user.health_journal_entries.where(entry_date: @start..(@start + 6.days)).order(:entry_date).to_a
      @averages = HealthJournalEntry::METRIC_FIELDS.to_h do |field|
        values = @days.filter_map { |day| day.public_send(field) }
        [field, { count: values.size, mean: values.any? ? (values.sum.to_f / values.size).round(1) : nil }]
      end
    end

    def extreme_days(field, direction)
      present = days.select { |day| day.public_send(field).present? }
      return [] if present.empty?
      target = present.map { |day| day.public_send(field) }.public_send(direction)
      present.select { |day| day.public_send(field) == target }.map(&:entry_date)
    end
  end
end
