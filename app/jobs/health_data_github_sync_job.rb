class HealthDataGithubSyncJob < ApplicationJob
  self.queue_adapter = ActiveJob::QueueAdapters::AsyncAdapter.new(min_threads: 0, max_threads: 2, idletime: 60)

  retry_on Health::DataGithubSync::Busy, wait: 5.seconds, attempts: 5
  retry_on Writing::GithubClient::Error, wait: 1.minute, attempts: 3
  discard_on Writing::GithubClient::RepositoryUnavailable

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    Health::DataGithubSync.new(user).call
    self.class.set(wait: 2.seconds).perform_later(user_id) if user.health_data_github_syncs.outstanding.exists?
  end
end
