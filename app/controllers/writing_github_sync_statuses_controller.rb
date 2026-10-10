class WritingGithubSyncStatusesController < ApplicationController
  def index
    response.headers["Cache-Control"] = "private, no-store"
    books = current_user.writing_books
    selected = books.find(params[:writing_book_id]) if params[:writing_book_id].present?
    pending_ids = WritingGithubSync.where(pending_changes: true).select(:writing_book_id)
    scope = books.where(id: pending_ids)
    scope = scope.or(books.where(id: selected.id)) if selected
    states = scope.includes(:writing_github_sync).order(:id).map do |book|
      Writing::GithubSyncStatus.new(book).as_json.merge(sync_url: writing_book_writing_github_sync_path(book))
    end
    render json: { configured: Writing::GithubConfiguration.new.configured?, states: states }
  end
end
