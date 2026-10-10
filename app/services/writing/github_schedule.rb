module Writing
  class GithubSchedule
    WINDOW = 5.minutes

    def self.mark_changed(book_id)
      # Lock the parent only while creating/updating scheduling metadata. Never
      # hold this lock during publication or wait for the publication advisory lock.
      WritingGithubSync.transaction do
        return unless WritingBook.where(id: book_id).lock("FOR KEY SHARE").pick(:id)

        state = WritingGithubSync.find_or_create_by!(writing_book_id: book_id)
        state.with_lock do
          now = Time.current
          state.content_revision += 1
          if state.sending_revision.present?
            state.next_pending_at ||= now
          end
          unless state.pending_changes?
            state.first_pending_at = now
            state.scheduled_at = now + WINDOW
          end
          state.pending_changes = true
          state.save!
        end
      end
    rescue StandardError => error
      # Content is already committed. A scheduling problem must never report a
      # failed save or prevent further writing; do not log manuscript data.
      Rails.logger.error("Writing GitHub scheduling failed for book #{book_id}: #{error.class}")
    end

    def initialize(book, automatic: false)
      @book = book
      @automatic = automatic
    end

    def call
      WritingGithubSync.connection_pool.with_connection do |connection|
        key = connection.quote("writing_github_sync:#{@book.id}")
        acquired = connection.select_value("SELECT pg_try_advisory_lock(hashtextextended(#{key}, 0))")
        raise GithubSync::Busy, "Este livro já está sendo sincronizado. Aguarde a conclusão." unless acquired

        begin
          @state = WritingGithubSync.find_or_create_by!(writing_book_id: @book.id)
          started = prepare
          return GithubSync::Result.new(state: @state, success: true, message: "Aguardando o horário previsto para sincronização.") unless started

          # PostgreSQL session advisory locks are reentrant. The existing service
          # acquires/releases its own level on this same checked-out connection.
          # The publication implementation remains unchanged.
          result = GithubSync.new(@book).call
          finish(result.success)
          result.state.reload
          result
        ensure
          connection.select_value("SELECT pg_advisory_unlock(hashtextextended(#{key}, 0))")
        end
      end
    end

    private

    def prepare
      @state.with_lock do
        return false if @automatic && (!@state.pending_changes? || @state.next_attempt_at > Time.current)

        now = Time.current
        @state.update!(sending_revision: @state.content_revision, next_pending_at: nil,
          pending_changes: true, first_pending_at: @state.first_pending_at || now,
          scheduled_at: @state.scheduled_at || now + WINDOW, retry_at: now + WINDOW)
      end
      true
    end

    def finish(success)
      @state.with_lock do
        now = Time.current
        if success
          @state.synced_revision = @state.sending_revision
          @state.pending_changes = @state.content_revision > @state.synced_revision
          @state.first_pending_at = @state.pending_changes? ? (@state.next_pending_at || now) : nil
          @state.scheduled_at = @state.first_pending_at && @state.first_pending_at + WINDOW
          @state.retry_at = nil
        else
          @state.pending_changes = true
          @state.first_pending_at ||= now
          @state.scheduled_at ||= @state.first_pending_at + WINDOW
          @state.retry_at = now + WINDOW
        end
        @state.sending_revision = nil
        @state.next_pending_at = nil
        @state.save!
      end
    end
  end
end
