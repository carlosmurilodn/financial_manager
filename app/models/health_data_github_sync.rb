class HealthDataGithubSync < ApplicationRecord
  belongs_to :user

  scope :outstanding, -> { where("revision > synced_revision") }

  def self.mark_pending(user_id, dates)
    rows = Array(dates).compact.uniq.map do |date|
      { user_id: user_id, occurred_on: date, revision: 1, synced_revision: 0,
        status: "pending", error_message: nil, created_at: Time.current, updated_at: Time.current }
    end
    return if rows.empty?

    upsert_all(rows, unique_by: [:user_id, :occurred_on], on_duplicate: Arel.sql(
      "revision = health_data_github_syncs.revision + 1, status = 'pending', error_message = NULL, updated_at = EXCLUDED.updated_at"
    ))
  end
end
