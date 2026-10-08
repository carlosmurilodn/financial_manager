class MuscleGroupsController < ApplicationController
  before_action :set_muscle_group, only: %i[edit update destroy]

  def index
    load_muscle_groups
  end

  def clear_filters
    session.delete(:muscle_groups_name)
    session.delete(:muscle_groups_status)

    redirect_to muscle_groups_path, notice: "Filtros limpos com sucesso!"
  end

  def new
    @muscle_group = current_user.muscle_groups.new(active: true)
  end

  def edit
  end

  def create
    @muscle_group = current_user.muscle_groups.new(muscle_group_params)
    @muscle_group.position = next_position if @muscle_group.position.to_i.zero?

    if @muscle_group.save
      redirect_to muscle_groups_path, notice: "Grupo muscular criado com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @muscle_group.update(muscle_group_params)
      redirect_to muscle_groups_path, notice: "Grupo muscular atualizado com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @muscle_group.destroy!
    redirect_to muscle_groups_path, notice: "Grupo muscular excluído com sucesso!", status: :see_other
  end

  private

  def load_muscle_groups
    session[:muscle_groups_name] = params[:name].to_s.strip if params.key?(:name)
    session[:muscle_groups_status] = params[:status].to_s if params.key?(:status)

    @name_filter = session[:muscle_groups_name].to_s
    @status_filter = session[:muscle_groups_status].to_s

    muscle_groups = current_user.muscle_groups.includes(:strength_exercise_catalogs).ordered
    muscle_groups = muscle_groups.where("name ILIKE ?", "%#{@name_filter}%") if @name_filter.present?
    muscle_groups = muscle_groups.where(active: @status_filter == "active") if %w[active inactive].include?(@status_filter)

    @filtered_count = muscle_groups.count
    @muscle_groups = paginate_collection(muscle_groups.to_a, per_page: pagination_per_page(:muscle_groups_per_page))
  end

  def set_muscle_group
    @muscle_group = current_user.muscle_groups.find(params[:id])
  end

  def muscle_group_params
    params.require(:muscle_group).permit(:name, :active, :position)
  end

  def next_position
    current_user.muscle_groups.maximum(:position).to_i + 1
  end
end
