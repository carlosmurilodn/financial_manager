class WritingProductivityController < ApplicationController
  def show
    @book = current_user.writing_books.find(params[:writing_book_id])
    response.headers["Cache-Control"] = "no-store, private"
    @period = Writing::ProductivityReport::PERIODS.key?(params[:period]) ? params[:period] : "30"
    @chapters = @book.writing_chapters.ordered.to_a
    historical_titles = @book.writing_activity_events.order(:id).pluck(:chapter_id, :chapter_title).to_h
    current_titles = @chapters.to_h { |chapter| [ chapter.id, chapter.title ] }
    @chapter_options = current_titles.merge(historical_titles.except(*current_titles.keys).transform_values { |title| "#{title} (Excluído)" })
    if params[:chapter_id].present?
      id = params[:chapter_id].to_s
      raise ActiveRecord::RecordNotFound unless id.match?(/\A\d+\z/) && @chapter_options.key?(id.to_i)

      @chapter = @chapters.find { |chapter| chapter.id == id.to_i } ||
        Struct.new(:id, :title).new(id.to_i, historical_titles.fetch(id.to_i))
    end
    preference = current_user.respond_to?(:time_zone) ? current_user.time_zone : nil
    @zone = ActiveSupport::TimeZone[preference.to_s] || Time.zone
    @report = Writing::ProductivityReport.new(@book, period: @period, chapter_id: @chapter&.id, zone: @zone)
  end
end
