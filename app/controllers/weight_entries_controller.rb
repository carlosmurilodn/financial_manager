class WeightEntriesController < ApplicationController
  before_action :set_weight_entry, only: %i[edit update destroy]

  def index
    @measured_from_filter = params[:measured_from].to_s.strip
    @measured_to_filter = params[:measured_to].to_s.strip

    @weight_entries = current_user.weight_entries.recent
    @weight_entries = @weight_entries.where(measured_on: measured_from..) if measured_from
    @weight_entries = @weight_entries.where(measured_on: ..measured_to) if measured_to

    @latest_weight_entry = current_user.weight_entries.recent.first
    @initial_weight_entry = current_user.weight_entries.order(:measured_on).first
    @filtered_count = @weight_entries.count
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
    @weight_entry.destroy!
    redirect_to weight_entries_path, notice: "Medição excluída com sucesso!", status: :see_other
  end

  private

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
    if @weight_entry.save
      redirect_to weight_entries_path, notice: notice, status: :see_other
    else
      render template, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @weight_entry.errors.add(:measured_on, "já possui uma medição. Edite o registro existente.")
    render template, status: :unprocessable_entity
  end
end
