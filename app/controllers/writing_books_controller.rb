class WritingBooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy cover read]

  def index
    books = current_user.writing_books
    @counts = books.group(:status).count
    @total_count = @counts.values.sum
    @title_filter = params[:title].to_s.strip
    @author_filter = params[:author].to_s.strip
    @genre_filter = params[:genre].to_s
    @status_filter = params[:status].to_s
    books = books.where("title ILIKE ?", "%#{WritingBook.sanitize_sql_like(@title_filter)}%") if @title_filter.present?
    books = books.where("author ILIKE ?", "%#{WritingBook.sanitize_sql_like(@author_filter)}%") if @author_filter.present?
    books = books.where(genre: @genre_filter) if @genre_filter.present?
    books = books.where(status: @status_filter) if @status_filter.present?
    sort, direction = params[:order_by].present? ? params[:order_by].to_s.split(":", 2) : [ params[:sort], params[:direction] ]
    @sort = %w[title created_at updated_at].include?(sort) ? sort : "updated_at"
    @direction = %w[asc desc].include?(direction) ? direction : (@sort == "title" ? "asc" : "desc")
    @filtered_count = books.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @books = books.order(@sort => @direction, id: :desc).with_attached_cover.limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
  end

  def read
    @chapters = @book.writing_chapters.ordered.preload(:writing_scenes)
    response.headers["Cache-Control"] = "private, no-store"
  end

  def new
    @book = current_user.writing_books.new
  end

  def edit
  end

  def create
    @book = current_user.writing_books.new(book_params)
    if @book.save
      redirect_to @book, notice: "Livro criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      if ActiveModel::Type::Boolean.new.cast(params.dig(:writing_book, :remove_cover)) && params.dig(:writing_book, :cover).blank?
        @book.cover.purge if @book.cover.attached?
      end
      redirect_to @book, notice: "Livro atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy!
    redirect_to writing_books_path, notice: "Livro excluído com sucesso!", status: :see_other
  end

  def cover
    return head :not_found unless @book.cover.attached?

    response.headers["Cache-Control"] = "private, no-store"
    send_data @book.cover.download, type: @book.cover.content_type, disposition: "inline"
  rescue ActiveStorage::FileNotFoundError
    head :not_found
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:id])
  end

  def book_params
    permitted = params.require(:writing_book).permit(:title, :subtitle, :author, :genre, :target_audience,
      :synopsis, :premise, :notes, :status, :started_on, :expected_completion_on, :cover, secondary_genres: [])
    permitted.delete(:cover) if permitted[:cover].blank?
    %i[started_on expected_completion_on].each do |field|
      next unless permitted[field].to_s.include?("/")

      permitted[field] = parse_brazilian_date(permitted[field])
    end
    permitted
  end
end
