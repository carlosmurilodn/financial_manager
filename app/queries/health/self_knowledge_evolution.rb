module Health
  class SelfKnowledgeEvolution
    PERIODS = { "30" => 30, "90" => 90, "180" => 180, "365" => 365, "all" => nil }.freeze
    attr_reader :period, :days, :averages, :needs, :steps, :legacy_weeks, :routines, :legacy_originals

    def initialize(user, period)
      @period = PERIODS.key?(period) ? period : "30"
      from = PERIODS[@period] && Date.current - (PERIODS[@period] - 1).days
      journals = user.health_journal_entries.where(entry_date: ..Date.current)
      reflections = user.health_weekly_reflections.where(week_start: ..Date.current)
      legacy = user.weekly_health_reviews.where(review_kind: "weekly", week_start: ..Date.current)
      if from
        journals = journals.where(entry_date: from..)
        reflections = reflections.where(week_start: from.beginning_of_week..)
        legacy = legacy.where(week_start: from.beginning_of_week..)
      end
      @days = journals.order(:entry_date).to_a
      @averages = HealthJournalEntry::METRIC_FIELDS.to_h do |field|
        values = @days.filter_map { |day| day.public_send(field) }
        [field, { count: values.size, mean: values.any? ? (values.sum.to_f / values.size).round(1) : nil }]
      end
      weeks = reflections.order(week_start: :desc).to_a
      @needs = (days.flat_map(&:needs) + weeks.flat_map(&:weekly_needs)).tally.sort_by { |name, count| [-count, name] }
      @steps = weeks.select { |week| week.next_small_step.present? }
      @routines = weeks.select { |week| week.routine_satisfaction.present? }
      @legacy_originals = user.weekly_wellbeings.where(id: legacy.where.not(legacy_wellbeing_id: nil).select(:legacy_wellbeing_id)).index_by(&:id)
      @legacy_weeks = legacy.order(week_start: :desc).to_a.select { |week| %i[energy mood anxiety overload routine_satisfaction].any? { |field| week.public_send(field).present? } }
    end
  end
end
