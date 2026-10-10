class WritingContextExportJob < ApplicationJob
  self.queue_adapter = ActiveJob::QueueAdapters::AsyncAdapter.new(min_threads: 0, max_threads: 2, idletime: 60)

  def perform(key, user_id, book_id, cleanup: false)
    store = Writing::ContextExportStore.new(key)
    return store.remove if cleanup

    store.with_lock do
      data = store.read
      return if data["state"].in?(%w[ready failed])
      raise Writing::ContextExportStore::Missing unless data["user_id"] == user_id && data["book_id"] == book_id

      store.update("state" => "processing", "message" => "Reunindo manuscrito e contexto literário…")
      book = User.find(user_id).writing_books.find(book_id)
      options = Writing::ContextExportOptions.new(data.fetch("settings"))
      filename = Writing::ContextExport.new(book, options).generate(store.zip_path)
      store.update("state" => "ready", "message" => "ZIP pronto. Baixe o pacote para anexá-lo à conversa no ChatGPT.", "filename" => filename)
    end
  rescue Writing::ContextExportStore::Missing, Errno::ENOENT
    nil
  rescue Writing::ContextExport::Error, ActiveRecord::RecordNotFound => error
    message = error.is_a?(Writing::ContextExport::Error) ? error.message : "Livro indisponível. Atualize a página e gere novamente."
    mark_failed(store, message)
  rescue StandardError => error
    Rails.logger.error("Writing context export failed: #{error.class}")
    mark_failed(store, "Não foi possível gerar o ZIP. Tente novamente; os dados originais foram preservados.")
  ensure
    self.class.set(wait: Writing::ContextExportStore::TTL).perform_later(key, user_id, book_id, cleanup: true) unless cleanup
  end

  private

  def mark_failed(store, message)
    FileUtils.rm_f(store.zip_path) if store
    store&.update("state" => "failed", "message" => message)
  rescue Writing::ContextExportStore::Missing
    nil
  end
end
