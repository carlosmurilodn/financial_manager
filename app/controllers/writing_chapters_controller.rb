class WritingChaptersController < ApplicationController
  before_action :set_book
  before_action :set_chapter, only: %i[show edit update destroy export reorder]

  def new
    @chapter = @book.writing_chapters.new
  end

  def show
    render "writing_chapters/show"
  end

  def edit
  end

  def create
    @chapter = @book.writing_chapters.new(chapter_params.merge(position: @book.writing_chapters.maximum(:position).to_i + 1))
    if @chapter.save
      saved_response(:created)
    else
      invalid_response(:new)
    end
  end

  def update
    if @chapter.update(chapter_params)
      saved_response(:ok)
    else
      invalid_response(:edit)
    end
  rescue ActiveRecord::StaleObjectError
    respond_to do |format|
      format.json { render json: { errors: [ "Este texto foi atualizado em outra aba. Copie seu texto antes de recarregar para evitar perder alterações." ] }, status: :conflict }
      format.html do
        @chapter.errors.add(:base, "O texto foi atualizado em outra aba. Reabra o editor antes de salvar.")
        render "writing_chapters/edit", status: :conflict
      end
    end
  end

  def destroy
    @chapter.destroy!
    redirect_to writing_book_path(@book), notice: "Capítulo excluído com sucesso!", status: :see_other
  end

  def reorder
    @book.with_lock do
      chapters = @book.writing_chapters.ordered.to_a
      index = chapters.index { |chapter| chapter.id == @chapter.id }
      offset = params[:direction] == "up" ? -1 : (params[:direction] == "down" ? 1 : 0)
      destination = index + offset
      if offset.nonzero? && destination.between?(0, chapters.length - 1)
        chapters[index], chapters[destination] = chapters[destination], chapters[index]
        chapters.each_with_index { |chapter, position| chapter.update_columns(position: position) }
      end
    end
    redirect_to writing_book_path(@book), notice: "Ordem dos capítulos atualizada.", status: :see_other
  end

  def export
    response.headers["Cache-Control"] = "private, no-store"
    filename = "#{@chapter.title.parameterize.presence || 'capitulo'}.html"
    send_data render_to_string(template: "writing_chapters/export", layout: false), type: "text/html; charset=utf-8", disposition: "attachment", filename: filename
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def set_chapter
    @chapter = @book.writing_chapters.find(params[:id])
  end

  def chapter_params
    permitted = params.require(:writing_chapter).permit(:title, :lock_version)
    permitted[:content] = JSON.parse(params.dig(:writing_chapter, :content)) if params.dig(:writing_chapter, :content).is_a?(String)
    permitted
  rescue JSON::ParserError, JSON::NestingError
    permitted[:content] = nil
    permitted
  end

  def saved_response(status)
    respond_to do |format|
      format.json do
        render json: {
          message: "Capítulo salvo.",
          lock_version: @chapter.lock_version,
          save_url: writing_book_writing_chapter_path(@book, @chapter),
          edit_url: edit_writing_book_writing_chapter_path(@book, @chapter),
          export_url: export_writing_book_writing_chapter_path(@book, @chapter),
          context_url: writing_book_writing_narrative_context_path(@book, chapter_id: @chapter.id),
          updated_at: @chapter.updated_at.iso8601
        }, status: status
      end
      format.html { redirect_to edit_writing_book_writing_chapter_path(@book, @chapter), notice: "Capítulo salvo com sucesso!", status: :see_other }
    end
  end

  def invalid_response(template)
    respond_to do |format|
      format.json { render json: { errors: @chapter.errors.full_messages }, status: :unprocessable_entity }
      format.html { render template, status: :unprocessable_entity }
    end
  end
end
