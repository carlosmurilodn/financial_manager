class WritingContextExportsController < ApplicationController
  before_action :set_book
  before_action :private_response

  def show
    Writing::ContextExportStore.cleanup
    @options = Writing::ContextExportOptions.new
    if params[:token].present?
      _store, data = authorized_export
      @options = Writing::ContextExportOptions.new(data.fetch("settings"))
      @export_urls = export_urls(params[:token])
    end
  rescue Writing::ContextExportStore::Missing
    redirect_to writing_book_writing_context_export_path(@book), alert: "Exportação expirada ou indisponível. Gere um novo ZIP.", status: :see_other
  end

  def create
    @options = Writing::ContextExportOptions.new(export_params)
    return render_error(@options.errors.full_messages, :unprocessable_content) unless @options.valid?

    Writing::ContextExportStore.cleanup
    if Writing::ContextExportStore.active_count(current_user.id) >= 2
      return render_error([ "Há duas exportações em processamento. Aguarde a conclusão." ], :too_many_requests)
    end
    store = Writing::ContextExportStore.new
    store.create(user_id: current_user.id, book_id: @book.id, settings: @options.attributes)
    token = Rails.application.message_verifier(:writing_context_export).generate(
      { "key" => store.key, "user_id" => current_user.id, "book_id" => @book.id },
      expires_in: Writing::ContextExportStore::TTL, purpose: "book_context_zip")
    begin
      job = WritingContextExportJob.perform_later(store.key, current_user.id, @book.id)
      raise ActiveJob::EnqueueError unless job
    rescue StandardError => error
      store.remove
      Rails.logger.error("Writing context export enqueue failed: #{error.class}")
      return render_error([ "Não foi possível iniciar a exportação. Tente novamente." ], :service_unavailable)
    end
    respond_to do |format|
      format.json { render json: export_urls(token).merge(state: "queued", message: "Exportação iniciada."), status: :accepted }
      format.html { redirect_to writing_book_writing_context_export_path(@book, token: token), notice: "Exportação iniciada.", status: :see_other }
    end
  end

  def status
    _store, data = authorized_export
    render json: data.slice("state", "message").merge(export_urls(params[:token]))
  rescue Writing::ContextExportStore::Missing
    render json: { state: "failed", message: "Exportação expirada ou indisponível. Gere um novo ZIP." }, status: :gone
  end

  def download
    store, data = authorized_export
    raise Writing::ContextExportStore::Missing unless data["state"] == "ready" && store.zip_path.file?

    response.headers["X-Content-Type-Options"] = "nosniff"
    send_file store.zip_path, filename: data.fetch("filename"), type: "application/zip", disposition: "attachment"
  rescue Writing::ContextExportStore::Missing
    redirect_to writing_book_writing_context_export_path(@book), alert: "ZIP indisponível ou expirado. Gere novamente.", status: :see_other
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def private_response
    response.headers["Cache-Control"] = "private, no-store"
    response.headers["Referrer-Policy"] = "same-origin"
  end

  def export_params
    { groups: params.require(:context_export).permit(groups: []).fetch(:groups, []) }
  end

  def authorized_export
    payload = Rails.application.message_verifier(:writing_context_export).verified(params[:token].to_s, purpose: "book_context_zip")
    unless payload.is_a?(Hash) && payload["user_id"] == current_user.id && payload["book_id"] == @book.id
      raise Writing::ContextExportStore::Missing
    end
    store = Writing::ContextExportStore.new(payload.fetch("key"))
    data = store.read
    raise Writing::ContextExportStore::Missing unless data["user_id"] == current_user.id && data["book_id"] == @book.id

    [ store, data ]
  end

  def export_urls(token)
    {
      status_url: status_writing_book_writing_context_export_path(@book, token: token),
      download_url: download_writing_book_writing_context_export_path(@book, token: token)
    }
  end

  def render_error(messages, status)
    respond_to do |format|
      format.json { render json: { errors: messages }, status: status }
      format.html { redirect_to writing_book_writing_context_export_path(@book), alert: messages.join(" "), status: :see_other }
    end
  end
end
