module HealthDataGithubTracking
  extend ActiveSupport::Concern

  included do
    after_save :track_health_data_github_changes
    after_destroy :track_health_data_github_changes
  end

  private

  def track_health_data_github_changes
    health_data_github_coordinates.each do |owner_id, dates|
      next unless owner_id && User.exists?(owner_id)

      HealthDataGithubSync.mark_pending(owner_id, dates)
      ActiveRecord.after_all_transactions_commit { enqueue_health_data_github_sync(owner_id) }
    end
  end

  def enqueue_health_data_github_sync(owner_id)
    return unless Health::DataGithubConfiguration.new.configured?

    HealthDataGithubSyncJob.perform_later(owner_id)
  rescue StandardError => error
    # Pending revisions remain available for manual resend after queue failure/restart.
    Rails.logger.error("Health data GitHub enqueue failed: #{error.class}")
  end
end
