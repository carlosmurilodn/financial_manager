module ControllerPagination
  extend ActiveSupport::Concern

  PER_PAGE_OPTIONS = [ 10, 25, 50, 100 ].freeze
  DEFAULT_PER_PAGE = 10

  private

  def pagination_per_page(_session_key = nil)
    sanitized_per_page(params[:per_page])
  end

  def paginate_collection(collection, per_page:)
    @per_page = per_page
    @total_pages = [ (collection.size.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i
    @current_page = 1 if @current_page < 1
    @current_page = @total_pages if @current_page > @total_pages

    offset = (@current_page - 1) * @per_page
    collection.slice(offset, @per_page) || []
  end

  def sanitized_per_page(value)
    per_page = value.to_i

    PER_PAGE_OPTIONS.include?(per_page) ? per_page : DEFAULT_PER_PAGE
  end
end
