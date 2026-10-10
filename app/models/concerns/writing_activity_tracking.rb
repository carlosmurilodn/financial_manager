module WritingActivityTracking
  extend ActiveSupport::Concern

  included do
    attr_accessor :writing_activity_operation
    around_save :track_writing_save
    around_destroy :track_writing_destroy, prepend: true
  end

  private

  def track_writing_save(&block)
    return yield unless new_record? || will_save_change_to_content?

    operation = writing_activity_operation.presence || (new_record? ? "create" : "edit")
    Writing::ActivityRecorder.track(self, operation, &block)
  end

  def track_writing_destroy(&block)
    Writing::ActivityRecorder.track(self, "destroy", &block)
  end
end
