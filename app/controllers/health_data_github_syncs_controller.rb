class HealthDataGithubSyncsController < ApplicationController
  def show
    @configuration = Health::DataGithubConfiguration.new
    @pending_count = current_user.health_data_github_syncs.outstanding.count
    @syncs = current_user.health_data_github_syncs.order(occurred_on: :desc).limit(100)
  end

  def create
    configuration = Health::DataGithubConfiguration.new
    unless configuration.configured?
      return redirect_to health_data_github_sync_path, alert: configuration.error_message, status: :see_other
    end

    attributes = params.permit(:date, :scope)
    dates = case attributes[:scope]
    when "history"
      current_user.weight_entries.distinct.pluck(:measured_on) |
        current_user.nutrition_meals.joins(:nutrition_meal_items).distinct.pluck(:occurred_on) |
        current_user.health_data_github_syncs.pluck(:occurred_on)
    when "day"
      [Date.iso8601(attributes[:date].to_s)]
    when "pending"
      current_user.health_data_github_syncs.outstanding.pluck(:occurred_on)
    else
      raise ArgumentError
    end
    dates.each_slice(500) { |batch| HealthDataGithubSync.mark_pending(current_user.id, batch) }
    HealthDataGithubSyncJob.perform_later(current_user.id) if dates.any?
    redirect_to health_data_github_sync_path,
      notice: dates.any? ? "Envio solicitado para #{dates.size} dia(s). Atualize esta página para acompanhar." : "Nenhum registro para enviar.",
      status: :see_other
  rescue ArgumentError
    redirect_to health_data_github_sync_path, alert: "Selecione um dia válido ou uma opção de envio.", status: :see_other
  rescue ActiveJob::EnqueueError
    redirect_to health_data_github_sync_path, alert: "Envio não iniciado. Pendências preservadas; tente novamente.", status: :see_other
  end
end
