class WeeklyHealthPlan < ApplicationRecord
  belongs_to :user
  has_many :weekly_health_goals, dependent: :destroy, inverse_of: :weekly_health_plan
  accepts_nested_attributes_for :weekly_health_goals, allow_destroy: true

  validates :week_start, presence: true, uniqueness: { scope: :user_id }
  validate :week_starts_on_monday

  def week_end
    week_start + 6.days
  end

  private

  def week_starts_on_monday
    if week_start.present? && !week_start.monday?
      errors.add(:week_start, "deve ser uma segunda-feira")
    end
  end
end
