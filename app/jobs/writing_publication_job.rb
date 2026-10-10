class WritingPublicationJob < ApplicationJob
  # The application's production adapter is inline. Isolate PDF work in a bounded
  # background pool without changing queues used by existing features.
  self.queue_adapter = ActiveJob::QueueAdapters::AsyncAdapter.new(min_threads: 0, max_threads: 2, idletime: 60)

  def perform(key, user_id, book_id, cleanup: false)
    store = Writing::PublicationStore.new(key)
    return store.remove if cleanup

    store.with_lock do
      data = store.read
      return if data["state"] == "ready"
      raise Writing::PublicationStore::Missing unless data["user_id"] == user_id && data["book_id"] == book_id

      book = User.find(user_id).writing_books.find(book_id)
      options = Writing::PublicationOptions.new(data.fetch("settings"))
      raise Writing::PublicationPdf::Error, options.errors.full_messages.join(" ") unless options.valid?

      store.update("state" => "processing", "message" => "Diagramando livro e calculando sumário…")
      family = Writing::PublicationPdf.new(book, options, store).generate
      filename = book.title.gsub(/[^\p{L}\p{N} _-]/, "").strip.gsub(/\s+/, "-")[0, 100].presence || "livro"
      store.update("state" => "ready", "message" => "PDF pronto para pré-visualização e download.", "filename" => "#{filename}.pdf", "font_family" => family)
    end
  rescue Writing::PublicationStore::Missing, Errno::ENOENT
    nil
  rescue Writing::PublicationPdf::Error, ActiveRecord::RecordNotFound => error
    message = error.is_a?(Writing::PublicationPdf::Error) ? error.message : "Livro ou capítulo indisponível. Atualize a seleção e gere novamente."
    mark_failed(store, message)
  rescue StandardError => error
    Rails.logger.error("Writing publication failed: #{error.class}")
    mark_failed(store, "Não foi possível gerar o PDF. Tente novamente; o manuscrito foi preservado.")
  ensure
    self.class.set(wait: Writing::PublicationStore::TTL).perform_later(key, user_id, book_id, cleanup: true) unless cleanup
  end

  private

  def mark_failed(store, message)
    store&.update("state" => "failed", "message" => message)
  rescue Writing::PublicationStore::Missing
    nil
  end
end
