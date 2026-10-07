class HealthProfilesController < ApplicationController
  before_action :set_health_profile

  def show
  end

  def create
    save_profile
  end

  def update
    save_profile
  end

  private

  def set_health_profile
    @health_profile = current_user.health_profile || current_user.build_health_profile
  end

  def health_profile_params
    attributes = params.require(:health_profile).permit(:height_cm, :birth_date, :formula_sex)
    attributes[:height_cm] = attributes[:height_cm].to_s.strip.tr(",", ".") if attributes.key?(:height_cm)
    attributes
  end

  def save_profile
    @health_profile.assign_attributes(health_profile_params)

    if @health_profile.save
      redirect_to health_profile_path, notice: "Perfil de Saúde salvo com sucesso!", status: :see_other
    else
      render :show, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @health_profile.errors.add(:base, "Seu perfil já foi salvo em outra sessão. Recarregue a página para editá-lo.")
    render :show, status: :unprocessable_entity
  end
end
