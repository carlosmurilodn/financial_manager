class PhilosophicalWorkshopConceptsController < ApplicationController
  before_action :set_concept, only: %i[show edit update destroy]
  before_action :load_philosophers, only: %i[new edit create update]

  def index
    scope = current_user.philosophical_workshop_concepts
    @title_filter = params[:title].to_s.strip
    scope = scope.where("title ILIKE ?", "%#{PhilosophicalWorkshopConcept.sanitize_sql_like(@title_filter)}%") if @title_filter.present?
    scope = scope.where(kind: params[:kind]) if params[:kind].present?
    @sort = %w[title kind created_at updated_at].include?(params[:sort]) ? params[:sort] : "title"
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    @filtered_count = scope.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @concepts = scope.order(@sort => @direction, id: :asc).limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
  end

  def new
    @concept = current_user.philosophical_workshop_concepts.new
  end

  def edit
  end

  def create
    @concept = current_user.philosophical_workshop_concepts.new(concept_params)
    if @concept.save
      redirect_to @concept, notice: "Registro criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @concept.update(concept_params)
      redirect_to @concept, notice: "Registro atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @concept.destroy!
    redirect_to philosophical_workshop_concepts_path, notice: "Registro excluído com sucesso!", status: :see_other
  end

  private

  def set_concept
    @concept = current_user.philosophical_workshop_concepts.find(params[:id])
  end

  def concept_params
    attributes = params.require(:philosophical_workshop_concept).permit(:title, :kind, :description, :premises, :arguments, :personal_notes, philosopher_ids: [])
    if attributes.key?(:philosopher_ids)
      ids = attributes[:philosopher_ids].reject(&:blank?).uniq
      current_user.philosophical_workshop_philosophers.find(ids) if ids.any?
      attributes[:philosopher_ids] = ids
    end
    attributes
  end

  def load_philosophers
    @philosophers = current_user.philosophical_workshop_philosophers.order(:name, :id)
  end
end
