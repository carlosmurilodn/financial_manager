class HealthJournalEntriesController < HealthPersonalRecordsController
  def sync_github
    @record = collection.find_by!(entry_date: valid_iso_date(params[:entry_date]))
    result = Health::JournalGithubSync.new(@record).call
    redirect_to record_path(@record), **(result.success ? { notice: result.message } : { alert: result.message }), status: :see_other
  end

  def prompt
    date = valid_iso_date(params[:date]) || Date.current
    record = collection.find_by(entry_date: date) || collection.build(entry_date: date)
    render json: { question: record.reflection_prompt.first, help: record.reflection_prompt.last }
  end

  private

  def finish_save(saved)
    result = Health::JournalGithubSync.new(@record).call if saved && !@existing_record
    super
    if result
      if result.success
        flash[:notice] = "#{flash[:notice]} #{result.message}"
      else
        flash[:alert] = "Diário salvo. Envio ao GitHub pendente: #{result.message}"
      end
    end
  end

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
