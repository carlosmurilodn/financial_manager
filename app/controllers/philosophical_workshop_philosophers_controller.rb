class PhilosophicalWorkshopPhilosophersController < ApplicationController
  before_action :set_philosopher, only: %i[show edit update destroy]

  def index
    scope = current_user.philosophical_workshop_philosophers
    @historical_periods = scope.where.not(historical_period: [ nil, "" ]).distinct.order(:historical_period).pluck(:historical_period)
    @philosophical_schools = scope.where.not(philosophical_school: [ nil, "" ]).distinct.order(:philosophical_school).pluck(:philosophical_school)
    @name_filter = params[:name].to_s.strip
    scope = scope.where("name ILIKE ?", "%#{PhilosophicalWorkshopPhilosopher.sanitize_sql_like(@name_filter)}%") if @name_filter.present?
    scope = scope.where(historical_period: params[:historical_period]) if params[:historical_period].present?
    scope = scope.where(philosophical_school: params[:philosophical_school]) if params[:philosophical_school].present?
    scope = scope.where(favorite: params[:favorite] == "true") if %w[true false].include?(params[:favorite])
    @sort = %w[name historical_period philosophical_school favorite created_at updated_at].include?(params[:sort]) ? params[:sort] : "name"
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    @filtered_count = scope.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @philosophers = scope.order(@sort => @direction, id: :asc).limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
  end

  def new
    @philosopher = current_user.philosophical_workshop_philosophers.new
  end

  def edit
  end

  def create
    @philosopher = current_user.philosophical_workshop_philosophers.new(philosopher_params)
    if @philosopher.save
      redirect_to @philosopher, notice: "Filósofo criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @philosopher.update(philosopher_params)
      redirect_to @philosopher, notice: "Filósofo atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @philosopher.destroy!
    redirect_to philosophical_workshop_philosophers_path, notice: "Filósofo excluído com sucesso!", status: :see_other
  end

  private

  def set_philosopher
    @philosopher = current_user.philosophical_workshop_philosophers.find(params[:id])
  end

  def philosopher_params
    params.require(:philosophical_workshop_philosopher).permit(:name, :historical_period, :philosophical_school, :biography, :main_ideas, :personal_notes, :favorite)
  end
end
