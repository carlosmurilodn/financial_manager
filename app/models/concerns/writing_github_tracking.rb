module WritingGithubTracking
  extend ActiveSupport::Concern

  included do
    class_attribute :github_export_fields, default: []
    after_save :remember_github_content_change
    after_destroy :remember_github_destruction
    after_commit :schedule_github_content_change
    after_rollback :clear_github_content_change
  end

  private

  def remember_github_content_change
    @github_content_changed ||= saved_change_to_id? || (saved_changes.keys & github_export_fields.map(&:to_s)).any?
  end

  def remember_github_destruction
    @github_content_changed = true
  end

  def schedule_github_content_change
    changed = @github_content_changed
    clear_github_content_change
    return unless changed
    return if is_a?(WritingBook) && destroyed?

    Writing::GithubSchedule.mark_changed(is_a?(WritingBook) ? id : writing_book_id)
  end

  def clear_github_content_change
    @github_content_changed = false
  end
end
