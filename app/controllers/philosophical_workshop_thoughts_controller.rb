class PhilosophicalWorkshopThoughtsController < ApplicationController
  before_action :set_thought, only: %i[show edit update destroy]
  before_action :load_questions, only: %i[new edit create update]

  def index
    scope = current_user.philosophical_workshop_thoughts
    @title_filter = params[:title].to_s.strip
    scope = scope.where("title ILIKE ?", "%#{PhilosophicalWorkshopThought.sanitize_sql_like(@title_filter)}%") if @title_filter.present?
    scope = scope.where(kind: params[:kind]) if params[:kind].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    @sort = %w[title kind status created_at updated_at].include?(params[:sort]) ? params[:sort] : "title"
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    @filtered_count = scope.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @thoughts = scope.order(@sort => @direction, id: :asc).limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
  end

  def new
    @thought = current_user.philosophical_workshop_thoughts.new
  end

  def edit
  end

  def create
    @thought = current_user.philosophical_workshop_thoughts.new(thought_params)
    if @thought.save
      redirect_to @thought, notice: "Pensamento criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @thought.update(thought_params)
      redirect_to @thought, notice: "Pensamento atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @thought.destroy!
    redirect_to philosophical_workshop_thoughts_path, notice: "Pensamento excluído com sucesso!", status: :see_other
  end

  private

  def set_thought
    @thought = current_user.philosophical_workshop_thoughts.find(params[:id])
  end

  def thought_params
    attributes = params.require(:philosophical_workshop_thought).permit(:title, :central_idea, :supporting_arguments, :counterpoints, :provisional_conclusion, :kind, :status, question_ids: [])
    if attributes.key?(:question_ids)
      ids = attributes[:question_ids].reject(&:blank?).map(&:to_i).uniq
      current_user.philosophical_workshop_questions.find(ids) if ids.any?
      attributes[:question_ids] = ids
    end
    attributes
  end

  def load_questions
    @questions = current_user.philosophical_workshop_questions.order(:question, :id)
  end
end
