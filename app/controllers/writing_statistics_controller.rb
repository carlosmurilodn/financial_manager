class WritingStatisticsController < ApplicationController
  def show
    @book = current_user.writing_books.find(params[:writing_book_id])
    response.headers["Cache-Control"] = "no-store, private"
    @statistics = Writing::ManuscriptStatistics.new(@book)
    @order = params[:order] == "words" ? "words" : "position"
    @include_common = params[:include_common] == "1"
    @chapters = @statistics.chapters
    @chapters = @chapters.sort_by { |chapter| [ -chapter[:words], chapter[:order] ] } if @order == "words"
    @frequent_words = @statistics.frequent_words(include_common: @include_common)
  end
end
