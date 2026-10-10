class PhilosophicalWorkshopInsightsController < ApplicationController
  before_action :set_insight, only: %i[show edit update destroy]

  def index
    scope = current_user.philosophical_workshop_insights
    @query = params[:query].to_s.strip
    if @query.present?
      pattern = "%#{PhilosophicalWorkshopInsight.sanitize_sql_like(@query)}%"
      scope = scope.where("content ILIKE ? OR origin ILIKE ? OR notes ILIKE ?", pattern, pattern, pattern)
    end
    scope = scope.where(status: params[:status]) if params[:status].present?
    @sort = %w[content status created_at updated_at].include?(params[:sort]) ? params[:sort] : "updated_at"
    @direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    @filtered_count = scope.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @insights = scope.order(@sort => @direction, id: :asc).limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
  end

  def new
    @insight = current_user.philosophical_workshop_insights.new
  end

  def edit
  end

  def create
    @insight = current_user.philosophical_workshop_insights.new(insight_params)
    if @insight.save
      redirect_to @insight, notice: "Insight criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @insight.update(insight_params)
      redirect_to @insight, notice: "Insight atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @insight.destroy!
    redirect_to philosophical_workshop_insights_path, notice: "Insight excluído com sucesso!", status: :see_other
  end

  private

  def set_insight
    @insight = current_user.philosophical_workshop_insights.find(params[:id])
  end

  def insight_params
    params.require(:philosophical_workshop_insight).permit(:content, :origin, :notes, :status)
  end
end
