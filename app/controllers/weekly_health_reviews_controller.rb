class WeeklyHealthReviewsController < ApplicationController
  before_action :set_review_key, only: %i[show edit update destroy]
  before_action :load_week_options, only: %i[new create edit update]

  def index
    load_weekly_health_reviews
  end

  def new
    @review_kind = "daily"
    @selected_date = Date.current
    @selected_week_number = current_week_number
    @week_start = @selected_date
    @weekly_health_review = current_user.weekly_health_reviews.find_or_initialize_by(review_kind: @review_kind, week_start: @week_start)
    @weekly_health_review.review_kind = @review_kind
  end

  def create
    assign_review_selection
    @weekly_health_review = current_user.weekly_health_reviews.find_or_initialize_by(review_kind: @review_kind, week_start: @week_start)
    @weekly_health_review.assign_attributes(weekly_health_review_params)
    @weekly_health_review.review_kind = @review_kind

    if @weekly_health_review.save
      redirect_to weekly_health_reviews_path, notice: "Perguntas da semana salvas com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @weekly_health_review = current_user.weekly_health_reviews.find_or_initialize_by(review_kind: @review_kind, week_start: @week_start)
    @selected_date = @weekly_health_review.week_start
    @selected_week_number = week_number_for(@weekly_health_review.week_start)
  end

  def show
    @weekly_health_review = current_user.weekly_health_reviews.find_by!(review_kind: @review_kind, week_start: @week_start)
  end

  def update
    saved = current_user.with_lock do
      @weekly_health_review = current_user.weekly_health_reviews.find_or_initialize_by(review_kind: @review_kind, week_start: @week_start)
      assign_review_selection
      @weekly_health_review.review_kind = @review_kind
      @weekly_health_review.week_start = @week_start
      @weekly_health_review.assign_attributes(weekly_health_review_params)
      @weekly_health_review.save
    end

    if saved
      redirect_to weekly_health_reviews_path, notice: "Perguntas da semana salvas com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @weekly_health_review.errors.add(:week_start, "já possui respostas. Edite a semana existente ou escolha outra semana.")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    weekly_health_review = current_user.weekly_health_reviews.find_by!(review_kind: @review_kind, week_start: @week_start)
    weekly_health_review.destroy!

    redirect_to weekly_health_reviews_path, notice: "Perguntas da semana excluídas com sucesso!", status: :see_other
  end

  def clear_filters
    session.delete(:weekly_health_reviews_week_from)
    session.delete(:weekly_health_reviews_week_to)

    redirect_to weekly_health_reviews_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def load_weekly_health_reviews
    session[:weekly_health_reviews_week_from] = params[:week_from].to_s.strip if params.key?(:week_from)
    session[:weekly_health_reviews_week_to] = params[:week_to].to_s.strip if params.key?(:week_to)

    @week_from_filter = session[:weekly_health_reviews_week_from].presence
    @week_to_filter = session[:weekly_health_reviews_week_to].presence

    reviews = current_user.weekly_health_reviews.order(week_start: :desc)
    reviews = reviews.where(week_start: week_from..) if week_from
    reviews = reviews.where(week_start: ..week_to) if week_to

    @latest_weekly_health_review = current_user.weekly_health_reviews.order(week_start: :desc).first
    @filtered_count = reviews.count
    @weekly_health_reviews = paginate_collection(reviews.to_a, per_page: pagination_per_page(:weekly_health_reviews_per_page))
    @week_from_label = week_from&.strftime("%d/%m/%Y")
  end

  def load_week_options
    @week_options = (1..52).map do |week_number|
      week_start = week_start_for_number(week_number)
      week_end = week_start + 6.days
      [ "Semana #{week_number} - De #{week_start.strftime("%d/%m/%Y")} a #{week_end.strftime("%d/%m/%Y")}", week_number ]
    end
  end

  def selected_week_number
    week_number = params[:week_number].to_i
    week_number.between?(1, 52) ? week_number : current_week_number
  end

  def current_week_number
    [[ Date.current.cweek, 1 ].max, 52 ].min
  end

  def week_number_for(date)
    [[ date.cweek, 1 ].max, 52 ].min
  end

  def week_start_for_number(week_number)
    Date.commercial(Date.current.cwyear, week_number, 1)
  end

  def set_week_start
    @week_start = Health::WeeklyPlan.week_start(params[:week_start])
  end

  def set_review_key
    @review_kind = params[:kind].presence_in(WeeklyHealthReview::REVIEW_KINDS.keys.map(&:to_s)) || "weekly"
    base_date = Date.iso8601(params[:week_start])
    @week_start = @review_kind == "weekly" ? Health::WeeklyPlan.week_start(base_date) : base_date
  rescue ArgumentError
    @week_start = Date.current
  end

  def assign_review_selection
    @review_kind = params[:review_kind].presence_in(WeeklyHealthReview::REVIEW_KINDS.keys.map(&:to_s)) || "daily"
    @selected_week_number = selected_week_number
    @selected_date = parse_form_date(params[:review_date]) || Date.current
    @week_start = @review_kind == "weekly" ? week_start_for_number(@selected_week_number) : @selected_date
  end

  def week_from
    parse_filter_date(@week_from_filter)
  end

  def week_to
    parse_filter_date(@week_to_filter)
  end

  def parse_filter_date(value)
    return if value.blank?

    Health::WeeklyPlan.week_start(Date.iso8601(value))
  rescue ArgumentError
    nil
  end

  def parse_form_date(value)
    return if value.blank?

    Date.strptime(value, "%d/%m/%Y")
  rescue ArgumentError
    nil
  end

  def weekly_health_review_params
    params.require(:weekly_health_review).permit(*WeeklyHealthReview::QUESTIONS.keys)
  end
end
