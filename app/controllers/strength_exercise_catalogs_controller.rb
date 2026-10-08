class StrengthExerciseCatalogsController < ApplicationController
  before_action :set_strength_exercise_catalog, only: %i[edit update destroy]

  def index
    load_strength_exercise_catalogs
  end

  def clear_filters
    session.delete(:strength_exercise_catalogs_name)
    session.delete(:strength_exercise_catalogs_muscle_group_id)
    session.delete(:strength_exercise_catalogs_status)

    redirect_to strength_exercise_catalogs_path, notice: "Filtros limpos com sucesso!"
  end

  def new
    @strength_exercise_catalog = current_user.strength_exercise_catalogs.new(active: true)
    load_muscle_group_options
  end

  def edit
    load_muscle_group_options
  end

  def create
    @strength_exercise_catalog = current_user.strength_exercise_catalogs.new(strength_exercise_catalog_params)
    @strength_exercise_catalog.position = next_position if @strength_exercise_catalog.position.to_i.zero?

    if @strength_exercise_catalog.save
      redirect_to strength_exercise_catalogs_path, notice: "Exercício de musculação criado com sucesso!", status: :see_other
    else
      load_muscle_group_options
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @strength_exercise_catalog.update(strength_exercise_catalog_params)
      remove_example_image_attachment_if_requested
      redirect_to strength_exercise_catalogs_path, notice: "Exercício de musculação atualizado com sucesso!", status: :see_other
    else
      load_muscle_group_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @strength_exercise_catalog.destroy!
    redirect_to strength_exercise_catalogs_path, notice: "Exercício de musculação excluído com sucesso!", status: :see_other
  end

  private

  def load_strength_exercise_catalogs
    session[:strength_exercise_catalogs_name] = params[:name].to_s.strip if params.key?(:name)
    session[:strength_exercise_catalogs_muscle_group_id] = params[:muscle_group_id].to_s if params.key?(:muscle_group_id)
    session[:strength_exercise_catalogs_status] = params[:status].to_s if params.key?(:status)

    @name_filter = session[:strength_exercise_catalogs_name].to_s
    @muscle_group_id_filter = session[:strength_exercise_catalogs_muscle_group_id].to_s
    @status_filter = session[:strength_exercise_catalogs_status].to_s

    strength_exercises = current_user.strength_exercise_catalogs.includes(:muscle_group).ordered
    strength_exercises = strength_exercises.where("strength_exercise_catalogs.name ILIKE ?", "%#{@name_filter}%") if @name_filter.present?
    strength_exercises = strength_exercises.where(muscle_group_id: @muscle_group_id_filter) if @muscle_group_id_filter.present?
    strength_exercises = strength_exercises.where(active: @status_filter == "active") if %w[active inactive].include?(@status_filter)

    @filtered_count = strength_exercises.count
    @strength_exercise_catalogs = paginate_collection(strength_exercises.to_a, per_page: pagination_per_page(:strength_exercise_catalogs_per_page))
    load_muscle_group_options
  end

  def load_muscle_group_options
    @muscle_group_options = current_user.muscle_groups.ordered
  end

  def set_strength_exercise_catalog
    @strength_exercise_catalog = current_user.strength_exercise_catalogs.find(params[:id])
  end

  def strength_exercise_catalog_params
    params.require(:strength_exercise_catalog).permit(:name, :muscle_group_id, :active, :position, :example_image)
  end

  def next_position
    current_user.strength_exercise_catalogs.maximum(:position).to_i + 1
  end

  def remove_example_image_attachment_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(params.dig(:strength_exercise_catalog, :remove_example_image))
    return if params.dig(:strength_exercise_catalog, :example_image).present?

    @strength_exercise_catalog.example_image.purge_later if @strength_exercise_catalog.example_image.attached?
  end
end
