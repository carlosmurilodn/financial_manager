class WeightEntriesController < ApplicationController
  before_action :set_weight_entry, only: %i[edit update destroy]

  def index
    load_weight_entries
  end

  def new
    @weight_entry = current_user.weight_entries.new(measured_on: Date.current)
  end

  def create
    @weight_entry = current_user.weight_entries.new(weight_entry_params)
    persist_weight_entry(:new, "Peso registrado com sucesso!")
  end

  def edit
  end

  def update
    @weight_entry.assign_attributes(weight_entry_params)
    persist_weight_entry(:edit, "Medição atualizada com sucesso!")
  end

  def destroy
    current_user.with_lock do
      @weight_entry.reload
      @weight_entry.destroy!
      Health::RecalculateDailyCalories.new(user: current_user, from: @weight_entry.measured_on).call
    end
    redirect_to weight_entries_path, notice: "Medição excluída com sucesso!", status: :see_other
  end

  def clear_filters
    session.delete(:weight_entries_measured_from)
    session.delete(:weight_entries_measured_to)

    redirect_to weight_entries_path, notice: "Filtros limpos com sucesso!"
  end

  private

  def load_weight_entries
    session[:weight_entries_measured_from] = params[:measured_from].to_s.strip if params.key?(:measured_from)
    session[:weight_entries_measured_to] = params[:measured_to].to_s.strip if params.key?(:measured_to)

    @measured_from_filter = session[:weight_entries_measured_from].presence
    @measured_to_filter = session[:weight_entries_measured_to].presence

    entries = current_user.weight_entries.recent
    entries = entries.where(measured_on: measured_from..) if measured_from
    entries = entries.where(measured_on: ..measured_to) if measured_to

    @latest_weight_entry = current_user.weight_entries.recent.first
    @initial_weight_entry = current_user.weight_entries.order(:measured_on).first
    @filtered_count = entries.count
    @weight_entries = paginate_collection(entries.to_a, per_page: pagination_per_page(:weight_entries_per_page))
  end

  def set_weight_entry
    @weight_entry = current_user.weight_entries.find(params[:id])
  end

  def weight_entry_params
    attributes = params.require(:weight_entry).permit(:measured_on, :weight_kg)
    attributes[:weight_kg] = attributes[:weight_kg].to_s.strip.tr(",", ".") if attributes.key?(:weight_kg)
    attributes
  end

  def measured_from
    parse_filter_date(@measured_from_filter)
  end

  def measured_to
    parse_filter_date(@measured_to_filter)
  end

  def parse_filter_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    nil
  end

  def persist_weight_entry(template, notice)
    saved = current_user.with_lock do
      previous_date = current_user.weight_entries.where(id: @weight_entry.id).pick(:measured_on) if @weight_entry.persisted?
      if @weight_entry.save
        first_affected_date = [ previous_date, @weight_entry.measured_on ].compact.min
        Health::RecalculateDailyCalories.new(user: current_user, from: first_affected_date).call
        true
      else
        false
      end
    end

    if saved
      redirect_to weight_entries_path, notice: notice, status: :see_other
    else
      render template, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @weight_entry.errors.add(:measured_on, "já possui uma medição. Edite o registro existente.")
    render template, status: :unprocessable_entity
  end
end
