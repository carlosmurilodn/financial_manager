class ApplicationController < ActionController::Base
  include BrazilianParameterParsing

  PER_PAGE_OPTIONS = [10, 25, 50, 100].freeze
  DEFAULT_PER_PAGE = 10
  SESSION_TIMEOUT = 30.minutes

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :require_login
  before_action :refresh_session_activity

  helper_method :current_user, :logged_in?, :show_sidebar?

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def logged_in?
    current_user.present?
  end

  def show_sidebar?
    logged_in? && !authentication_flow_page?
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    session[:last_seen_at] = Time.current.to_i
  end

  def sign_out
    reset_session
    @current_user = nil
  end

  def remember_passkey_email(user)
    cookies.permanent.signed[:last_passkey_email] = {
      value: user.email,
      httponly: true,
      same_site: :lax
    }
  end

  def require_login
    return if logged_in? && !session_expired?

    sign_out if session[:user_id].present?
    redirect_to login_path, alert: "Entre para continuar."
  end

  def session_expired?
    last_seen_at = session[:last_seen_at].to_i
    last_seen_at.positive? && Time.at(last_seen_at) < SESSION_TIMEOUT.ago
  end

  def refresh_session_activity
    session[:last_seen_at] = Time.current.to_i if logged_in?
  end

  def authentication_flow_page?
    controller_name.in?(%w[sessions users]) ||
      (controller_name == "passkeys" && action_name == "setup")
  end

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
