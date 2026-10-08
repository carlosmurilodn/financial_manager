class HealthJournalEntriesController < HealthPersonalRecordsController
  def prompt
    date = valid_iso_date(params[:date]) || Date.current
    record = collection.find_by(entry_date: date) || collection.build(entry_date: date)
    render json: { question: record.reflection_prompt.first, help: record.reflection_prompt.last }
  end

  private

  def set_area
    @area = "daily"
  end

  def date_field
    :entry_date
  end

  def collection
    current_user.health_journal_entries
  end

  def record_params
    params.require(:health_journal_entry).permit(:entry_date, *HealthJournalEntry::TEXT_FIELDS, *HealthJournalEntry::METRIC_FIELDS, needs: [])
  end
end
