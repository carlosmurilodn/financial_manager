class WeeklyHealthReviewsController < ApplicationController
  before_action :set_week_start

  def edit
    @weekly_health_review = current_user.weekly_health_reviews.find_or_initialize_by(week_start: @week_start)
  end

  def update
    saved = current_user.with_lock do
      @weekly_health_review = current_user.weekly_health_reviews.find_or_initialize_by(week_start: @week_start)
      @weekly_health_review.assign_attributes(weekly_health_review_params)
      @weekly_health_review.save
    end

    if saved
      redirect_to progress_path(week: @week_start.iso8601), notice: "Revisão da semana salva com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_week_start
    @week_start = Health::WeeklyPlan.week_start(params[:week_start])
  end

  def weekly_health_review_params
    params.require(:weekly_health_review).permit(*WeeklyHealthReview::QUESTIONS.keys)
  end
end
