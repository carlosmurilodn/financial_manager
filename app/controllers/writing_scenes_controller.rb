class WritingScenesController < WritingChaptersController
  before_action :set_chapter, only: :move

  def new
    parent = @book.writing_chapters.find(params[:writing_chapter_id])
    @chapter = @book.writing_scenes.new(writing_chapter: parent)
    render "writing_chapters/new"
  end

  def edit
    render "writing_chapters/edit"
  end

  def create
    attributes = chapter_params
    attributes[:position] = attributes[:writing_chapter].writing_scenes.maximum(:position).to_i + 1
    @chapter = @book.writing_scenes.new(attributes)
    if @chapter.save
      saved_response(:created)
    else
      invalid_response(:new)
    end
  end

  def destroy
    parent = @chapter.writing_chapter
    @chapter.destroy!
    redirect_to writing_book_writing_chapter_path(@book, parent), notice: "Cena excluída com sucesso!", status: :see_other
  end

  def move
    parent = @book.writing_chapters.find(params.require(:writing_chapter_id))
    @book.with_lock { @chapter.update_columns(writing_chapter_id: parent.id, position: parent.writing_scenes.maximum(:position).to_i + 1) }
    redirect_to writing_book_writing_scene_path(@book, @chapter), notice: "Cena movida. Texto e associações preservados.", status: :see_other
  end

  private

  def set_chapter
    @chapter = @book.writing_scenes.find(params[:id])
  end

  def chapter_params
    raw = params.require(:writing_scene)
    permitted = raw.permit(:title, :lock_version)
    unless @chapter&.persisted?
      permitted[:writing_chapter] = @book.writing_chapters.find(raw.require(:writing_chapter_id))
    end
    permitted[:content] = JSON.parse(raw[:content]) if raw[:content].is_a?(String)
    permitted
  rescue JSON::ParserError, JSON::NestingError
    permitted[:content] = nil
    permitted
  end

  def saved_response(status)
    respond_to do |format|
      format.json do
        render json: { message: "Cena salva.", lock_version: @chapter.lock_version,
          save_url: writing_book_writing_scene_path(@book, @chapter), edit_url: edit_writing_book_writing_scene_path(@book, @chapter),
          export_url: export_writing_book_writing_scene_path(@book, @chapter),
          context_url: writing_book_writing_narrative_context_path(@book, scene_id: @chapter.id), updated_at: @chapter.updated_at.iso8601 }, status: status
      end
      format.html { redirect_to edit_writing_book_writing_scene_path(@book, @chapter), notice: "Cena salva!", status: :see_other }
    end
  end

  def invalid_response(template)
    respond_to do |format|
      format.json { render json: { errors: @chapter.errors.full_messages }, status: :unprocessable_content }
      format.html { render "writing_chapters/#{template}", status: :unprocessable_content }
    end
  end
end
