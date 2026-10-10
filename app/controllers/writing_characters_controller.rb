class WritingCharactersController < ApplicationController
  before_action :set_book
  before_action :set_character, only: %i[show edit update destroy image]

  def index
    characters = @book.writing_characters
    @name_filter = params[:name].to_s.strip
    characters = characters.where("concat_ws(' ', name, surname, nicknames) ILIKE ?", "%#{WritingCharacter.sanitize_sql_like(@name_filter)}%") if @name_filter.present?
    characters = characters.where(role: params[:role]) if params[:role].present?
    characters = characters.where(status: params[:status]) if params[:status].present?
    @filtered_count = characters.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @characters = characters.order(:name, :id).with_attached_reference_image.limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
    @relationships = @character.relationships.includes(:source_character, :target_character).order(:id)
  end

  def new
    @character = @book.writing_characters.new
  end

  def edit
  end

  def create
    @character = @book.writing_characters.new(character_params)
    if @character.save
      redirect_to [ @book, @character ], notice: "Personagem criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @character.update(character_params)
      if ActiveModel::Type::Boolean.new.cast(params.dig(:writing_character, :remove_reference_image)) && params.dig(:writing_character, :reference_image).blank?
        @character.reference_image.purge if @character.reference_image.attached?
      end
      redirect_to [ @book, @character ], notice: "Personagem atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @character.destroy!
    redirect_to writing_book_writing_characters_path(@book), notice: "Personagem e relacionamentos excluídos!", status: :see_other
  end

  def image
    return head :not_found unless @character.reference_image.attached?

    response.headers["Cache-Control"] = "private, no-store"
    send_data @character.reference_image.download, type: @character.reference_image.content_type, disposition: "inline"
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def set_character
    @character = @book.writing_characters.find(params[:id])
  end

  def character_params
    fields = WritingCharacter::PROFILE_SECTIONS.values.flat_map(&:keys)
    permitted = params.require(:writing_character).permit(:name, :surname, :nicknames, :role, :status, :reference_image, *fields)
    permitted.delete(:reference_image) if permitted[:reference_image].blank?
    permitted
  end
end
