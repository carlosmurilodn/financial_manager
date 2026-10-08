class ExerciseEntriesController < ApplicationController
  before_action :set_exercise_entry, only: %i[edit update destroy duplicate]
  before_action :load_form_options, only: %i[new edit create update duplicate]

  def index
    load_exercise_entries
  end

  def clear_filters
    session.delete(:exercise_entries_date_from)
    session.delete(:exercise_entries_date_to)
    session.delete(:exercise_entries_type)

    redirect_to health_exercises_path, notice: "Filtros limpos com sucesso!"
  end

  def new
    @exercise_entry = current_user.exercise_entries.new(performed_on: Date.current)
    build_default_item
  end

  def edit
    build_missing_strength_logs
  end

  def duplicate
    @exercise_entry = duplicated_exercise_entry(@exercise_entry)
    render :new
  end

  def create
    @exercise_entry = current_user.exercise_entries.new(exercise_entry_params)
    normalize_items

    if @exercise_entry.save
      Health::RecalculateDailyCalories.new(user: current_user, dates: [@exercise_entry.performed_on]).call
      redirect_to health_exercises_path, notice: "Exercício criado com sucesso!", status: :see_other
    else
      build_missing_strength_logs
      render :new, status: :unprocessable_entity
    end
  end

  def update
    previous_date = @exercise_entry.performed_on
    @exercise_entry.assign_attributes(exercise_entry_params)
    normalize_items

    if @exercise_entry.save
      Health::RecalculateDailyCalories.new(user: current_user, dates: [previous_date, @exercise_entry.performed_on].uniq).call
      redirect_to health_exercises_path, notice: "Exercício atualizado com sucesso!", status: :see_other
    else
      build_missing_strength_logs
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    date = @exercise_entry.performed_on
    @exercise_entry.destroy!
    Health::RecalculateDailyCalories.new(user: current_user, dates: [date]).call
    redirect_to health_exercises_path, notice: "Exercício excluído com sucesso!", status: :see_other
  end

  private

  def load_exercise_entries
    session[:exercise_entries_date_from] = params[:date_from].to_s if params.key?(:date_from)
    session[:exercise_entries_date_to] = params[:date_to].to_s if params.key?(:date_to)
    session[:exercise_entries_type] = params[:exercise_type].to_s if params.key?(:exercise_type)

    @date_from_filter = session[:exercise_entries_date_from].to_s
    @date_to_filter = session[:exercise_entries_date_to].to_s
    @type_filter = session[:exercise_entries_type].to_s

    entries = current_user.exercise_entries.includes(exercise_items: { strength_exercise_logs: [ :muscle_group, :strength_exercise_catalog ] }).recent
    entries = entries.where(performed_on: Date.iso8601(@date_from_filter)..) if @date_from_filter.present?
    entries = entries.where(performed_on: ..Date.iso8601(@date_to_filter)) if @date_to_filter.present?
    entries = entries.joins(:exercise_items).where(exercise_items: { exercise_type: @type_filter }).distinct if ExerciseItem::TYPES.key?(@type_filter)

    @latest_exercise_entry = current_user.exercise_entries.recent.first
    @filtered_count = entries.count
    @exercise_entries = paginate_collection(entries.to_a, per_page: pagination_per_page(:exercise_entries_per_page))
  rescue ArgumentError
    session.delete(:exercise_entries_date_from)
    session.delete(:exercise_entries_date_to)
    redirect_to health_exercises_path, alert: "Filtro inválido."
  end

  def set_exercise_entry
    @exercise_entry = current_user.exercise_entries.find(params[:id])
  end

  def load_form_options
    @muscle_groups = current_user.muscle_groups.active.ordered.includes(:strength_exercise_catalogs)
    @strength_exercises = current_user.strength_exercise_catalogs.active.includes(:muscle_group).ordered
  end

  def build_default_item
    item = @exercise_entry.exercise_items.build(exercise_type: "training")
    item.strength_exercise_logs.build
  end

  def duplicated_exercise_entry(source)
    current_user.exercise_entries.new(performed_on: nil).tap do |entry|
      source.exercise_items.includes(:strength_exercise_logs).each do |source_item|
        item = entry.exercise_items.build(
          exercise_type: source_item.exercise_type,
          duration_minutes: source_item.duration_minutes,
          intensity: source_item.intensity,
          notes: source_item.notes
        )

        source_item.strength_exercise_logs.each do |source_log|
          item.strength_exercise_logs.build(
            muscle_group_id: source_log.muscle_group_id,
            strength_exercise_catalog_id: source_log.strength_exercise_catalog_id,
            sets: source_log.sets
          )
        end
      end
    end
  end

  def build_missing_strength_logs
    @exercise_entry.exercise_items.each do |item|
      item.strength_exercise_logs.build if item.training? && item.strength_exercise_logs.blank?
    end
  end

  def normalize_items
    @exercise_entry.exercise_items.each do |item|
      item.duration_minutes = nil if item.duration_minutes.to_s.blank?
      item.intensity = nil if item.intensity.blank?
      item.strength_exercise_logs.each(&:mark_for_destruction) unless item.training?
    end
  end

  def exercise_entry_params
    attributes = params.require(:exercise_entry).permit(
      :performed_on,
      exercise_items_attributes: [
        :id,
        :exercise_type,
        :duration_minutes,
        :intensity,
        :notes,
        :_destroy,
        strength_exercise_logs_attributes: [
          :id,
          :muscle_group_id,
          :strength_exercise_catalog_id,
          :sets,
          :_destroy
        ]
      ]
    )
    attributes[:performed_on] = parse_form_date(attributes[:performed_on])
    attributes
  end

  def parse_form_date(value)
    return if value.blank?
    return Date.iso8601(value) if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.strptime(value, "%d/%m/%Y")
  rescue ArgumentError
    value
  end
end
