class HealthDataGithubSyncsController < ApplicationController
  def show
    @configuration = Health::DataGithubConfiguration.new
    syncs = current_user.health_data_github_syncs
    counts = syncs.group(:status).count
    @pending_count = counts.fetch("pending", 0)
    @failed_count = counts.fetch("failed", 0)
    @succeeded_count = counts.fetch("succeeded", 0)
    @outstanding_count = @pending_count + @failed_count
    @last_success_at = syncs.maximum(:last_success_at)
    @last_error = syncs.where(status: "failed").where.not(error_message: nil)
      .order(Arel.sql("last_attempt_at DESC NULLS LAST"), id: :desc).first&.error_message
    @syncs = syncs.order(occurred_on: :desc).limit(100)
    render partial: "status" if turbo_frame_request_id == "health-data-github-status"
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
