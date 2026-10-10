class WritingScenesController < WritingChaptersController
  before_action :set_chapter, only: %i[show edit update destroy export move reorder]

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
    saved = @book.with_lock do
      attributes[:position] = attributes[:writing_chapter].writing_scenes.maximum(:position).to_i + 1
      @chapter = @book.writing_scenes.new(attributes)
      @chapter.save
    end
    if saved
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
    parent = @book.writing_chapters.where.not(id: @chapter.writing_chapter_id).find(params.require(:writing_chapter_id))
    Writing::ActivityRecorder.move(@chapter, parent) do
      @chapter.update!(writing_chapter_id: parent.id, position: parent.writing_scenes.maximum(:position).to_i + 1)
    end
    redirect_to writing_book_writing_scene_path(@book, @chapter), notice: "Cena movida. Texto e associações preservados.", status: :see_other
  end

  def reorder
    @book.with_lock do
      @chapter.reload
      scenes = @chapter.writing_chapter.writing_scenes.ordered.to_a
      index = scenes.index { |scene| scene.id == @chapter.id }
      offset = { "up" => -1, "down" => 1 }.fetch(params[:direction], 0)
      destination = index + offset
      if offset.nonzero? && destination.between?(0, scenes.length - 1)
        scenes[index], scenes[destination] = scenes[destination], scenes[index]
        scenes.each_with_index { |scene, position| scene.update!(position: position) if scene.position != position }
      end
    end
    redirect_to edit_writing_book_writing_chapter_path(@book, @chapter.writing_chapter), notice: "Ordem das cenas atualizada.", status: :see_other
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
