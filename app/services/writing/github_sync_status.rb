module Writing
  class GithubSyncStatus
    def initialize(book, state = nil)
      @book = book
      @state = state || book.writing_github_sync || book.build_writing_github_sync
    end

    def as_json(*)
      now = Time.current
      next_attempt = @state.next_attempt_at
      processing = @state.actively_processing?
      {
        book_id: @book.id, title: @book.title, status_label: @state.scheduling_label,
        pending: @state.pending_changes?, processing: processing,
        due: @state.pending_changes? && next_attempt.present? && next_attempt <= now && !processing,
        poll: @state.pending_changes? || processing,
        scheduled_at: next_attempt&.iso8601,
        scheduled_display: next_attempt ? I18n.l(next_attempt, format: :long) : nil,
        last_success: @state.last_success_at ? I18n.l(@state.last_success_at, format: :long) : nil,
        error_message: @state.error_message.presence || (@state.status == "processing" && !processing ? "Envio interrompido. A pendência será retomada pelo Estúdio." : nil)
      }
    end
  end
end
