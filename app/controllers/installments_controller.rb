class InstallmentsController < ApplicationController
  before_action :set_installment, only: %i[edit update destroy toggle_paid]

  def edit; end

  def update
    @installment.amount = normalize_amount(params[:installment][:amount])

    if @installment.update(installment_params.except(:amount))
      redirect_to expenses_path, notice: "Parcela atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @installment.destroy
    redirect_to expenses_path, notice: "Parcela removida com sucesso!"
  end

  def toggle_paid
    @installment.update(paid: !@installment.paid)
    redirect_to expenses_path
  end

  private

  def set_installment
    @installment = Installment.find(params[:id])
  end

  def installment_params
    params.require(:installment).permit(:amount, :paid)
  end

  def normalize_amount(amount_param)
    return 0 if amount_param.blank?
    cleaned = amount_param.to_s.gsub(/[^\d,\.]/, '')
    cleaned.tr!(',', '.') if cleaned.count(',') == 1 && cleaned.count('.') <= 1
    cleaned.gsub!('.', '') if cleaned.count('.') > 1
    cleaned.to_d
  end
end
