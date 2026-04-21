class ApplicationController < ActionController::Base
  include BrazilianParameterParsing

  PER_PAGE_OPTIONS = [10, 25, 50, 100].freeze
  DEFAULT_PER_PAGE = 10

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def pagination_per_page(_session_key = nil)
    sanitized_per_page(params[:per_page])
  end

  def paginate_collection(collection, per_page:)
    @per_page = per_page
    @total_pages = [(collection.size.to_f / @per_page).ceil, 1].max
    @current_page = params[:page].to_i
    @current_page = 1 if @current_page < 1
    @current_page = @total_pages if @current_page > @total_pages

    offset = (@current_page - 1) * @per_page
    collection.slice(offset, @per_page) || []
  end

  def sort_collection(collection, sort_map:, default_sort:, default_direction: "asc")
    @sort = sort_map.key?(params[:sort].to_s) ? params[:sort].to_s : default_sort.to_s
    fallback_direction = default_direction == "desc" ? "desc" : "asc"
    @direction = params.key?(:direction) ? (params[:direction] == "desc" ? "desc" : "asc") : fallback_direction

    sorter = sort_map.fetch(@sort)
    sorted_collection = collection.sort_by do |record|
      normalize_sort_value(sorter.call(record))
    end

    @direction == "desc" ? sorted_collection.reverse : sorted_collection
  end

  def per_page_options
    PER_PAGE_OPTIONS
  end
  helper_method :per_page_options

  def sanitized_per_page(value)
    per_page = value.to_i

    PER_PAGE_OPTIONS.include?(per_page) ? per_page : DEFAULT_PER_PAGE
  end

  def normalize_sort_value(value)
    case value
    when nil
      [1, ""]
    when String
      [0, value.downcase]
    when TrueClass, FalseClass
      [0, value ? 1 : 0]
    else
      [0, value]
    end
  end
end
