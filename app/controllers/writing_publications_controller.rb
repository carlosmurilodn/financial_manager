class WritingPublicationsController < ApplicationController
  before_action :set_book
  before_action :private_response

  def show
    Writing::PublicationStore.cleanup
    @chapters = @book.writing_chapters.ordered
    @options = Writing::PublicationOptions.new
    if params[:token].present?
      @store, @export = authorized_export
      @options = Writing::PublicationOptions.new(@export.fetch("settings"))
      @export_urls = export_urls(params[:token])
    end
    @font_families = Writing::PublicationOptions::FONTS.to_h { |font| [ font, Writing::PublicationFonts.new(font).family ] }
  rescue Writing::PublicationStore::Missing
    redirect_to writing_book_writing_publication_path(@book), alert: "Exportação expirada ou indisponível. Gere um novo PDF.", status: :see_other
  end

  def create
    @options = Writing::PublicationOptions.new(publication_params)
    unless @options.valid?
      return render_error(@options.errors.full_messages, :unprocessable_content)
    end
    @options.selected_chapters(@book).load
    Writing::PublicationStore.cleanup
    if Writing::PublicationStore.active_count(current_user.id) >= 2
      return render_error([ "Há duas exportações em processamento. Aguarde a conclusão antes de iniciar outra." ], :too_many_requests)
    end
    store = Writing::PublicationStore.new
    store.create(user_id: current_user.id, book_id: @book.id, settings: @options.attributes)
    token = Rails.application.message_verifier(:writing_publication).generate(
      { "key" => store.key, "user_id" => current_user.id, "book_id" => @book.id },
      expires_in: Writing::PublicationStore::TTL, purpose: "book_pdf")
    begin
      job = WritingPublicationJob.perform_later(store.key, current_user.id, @book.id)
      raise ActiveJob::EnqueueError unless job
    rescue StandardError => error
      store.remove
      Rails.logger.error("Writing publication enqueue failed: #{error.class}")
      return render_error([ "Não foi possível iniciar a exportação. Tente novamente." ], :service_unavailable)
    end
    respond_to do |format|
      format.json { render json: export_urls(token).merge(state: "queued", message: "Exportação iniciada. Pode continuar usando o Estúdio."), status: :accepted }
      format.html { redirect_to writing_book_writing_publication_path(@book, token: token), notice: "Exportação iniciada.", status: :see_other }
    end
  end

  def status
    _store, data = authorized_export
    render json: data.slice("state", "message", "font_family").merge(export_urls(params[:token]))
  rescue Writing::PublicationStore::Missing
    render json: { state: "failed", message: "Exportação expirada ou indisponível. Gere um novo PDF." }, status: :gone
  end

  def download
    store, data = authorized_export
    raise Writing::PublicationStore::Missing unless data["state"] == "ready" && store.pdf_path.file?

    response.headers["X-Content-Type-Options"] = "nosniff"
    send_file store.pdf_path, filename: data.fetch("filename"), type: "application/pdf",
      disposition: params[:download] == "1" ? "attachment" : "inline"
  rescue Writing::PublicationStore::Missing
    redirect_to writing_book_writing_publication_path(@book), alert: "PDF indisponível ou expirado. Gere novamente.", status: :see_other
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def private_response
    response.headers["Cache-Control"] = "private, no-store"
    response.headers["Referrer-Policy"] = "same-origin"
  end

  def publication_params
    fields = %i[page_format font font_size line_height alignment margins content_scope] + Writing::PublicationOptions::FLAGS.keys
    attributes = params.require(:publication).permit(*fields, chapter_ids: []).to_h
    attributes["chapter_ids"] = Array(attributes["chapter_ids"]).reject(&:blank?).uniq
    attributes
  end

  def authorized_export
    payload = Rails.application.message_verifier(:writing_publication).verified(params[:token].to_s, purpose: "book_pdf")
    unless payload.is_a?(Hash) && payload["user_id"] == current_user.id && payload["book_id"] == @book.id
      raise Writing::PublicationStore::Missing
    end
    store = Writing::PublicationStore.new(payload.fetch("key"))
    data = store.read
    raise Writing::PublicationStore::Missing unless data["user_id"] == current_user.id && data["book_id"] == @book.id

    [ store, data ]
  end

  def export_urls(token)
    {
      status_url: status_writing_book_writing_publication_path(@book, token: token),
      preview_url: download_writing_book_writing_publication_path(@book, token: token),
      download_url: download_writing_book_writing_publication_path(@book, token: token, download: "1")
    }
  end

  def render_error(messages, status)
    respond_to do |format|
      format.json { render json: { errors: messages }, status: status }
      format.html { redirect_to writing_book_writing_publication_path(@book), alert: messages.join(" "), status: :see_other }
    end
  end
end
