class WeightEntriesController < ApplicationController
  before_action :set_weight_entry, only: %i[edit update destroy]

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
    redirect_to progress_path, notice: "Medição excluída com sucesso!", status: :see_other
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

  def persist_weight_entry(template, notice)
    if @weight_entry.save
      redirect_to progress_path, notice: notice, status: :see_other
    else
      render template, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @weight_entry.errors.add(:measured_on, "já possui uma medição. Edite o registro existente.")
    render template, status: :unprocessable_entity
  end
end
