class WritingGithubSyncsController < ApplicationController
  before_action :set_book
  before_action :private_response

  def show
    @configuration = Writing::GithubConfiguration.new
    @sync = @book.writing_github_sync || @book.build_writing_github_sync
  end

  def create
    result = Writing::GithubSync.new(@book).call
    respond_to do |format|
      format.json { render json: state_payload(result.state).merge(message: result.message, success: result.success), status: result.success ? :ok : :unprocessable_content }
      format.html { redirect_to writing_book_writing_github_sync_path(@book), **(result.success ? { notice: result.message } : { alert: result.message }), status: :see_other }
    end
  rescue Writing::GithubSync::Busy => error
    respond_to do |format|
      format.json { render json: { message: error.message, success: false }, status: :conflict }
      format.html { redirect_to writing_book_writing_github_sync_path(@book), alert: error.message, status: :see_other }
    end
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def private_response
    response.headers["Cache-Control"] = "private, no-store"
  end

  def state_payload(state)
    {
      status_label: state.status_label,
      last_attempt: display_time(state.last_attempt_at), last_success: display_time(state.last_success_at),
      created_count: state.created_count, updated_count: state.updated_count, unchanged_count: state.unchanged_count,
      obsolete_files: state.obsolete_files
    }
  end

  def display_time(value)
    value ? I18n.l(value, format: :long) : "Ainda não registrada"
  end
end
