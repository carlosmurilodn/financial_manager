class WeeklyWellbeing < ApplicationRecord
  METRICS = { energy: "Energia", mood: "Humor", routine_satisfaction: "Satisfação com a rotina" }.freeze

  belongs_to :user
  validates :week_start, presence: true, uniqueness: { scope: :user_id }
  validates(*METRICS.keys, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 })
  validates :notes, length: { maximum: 2000 }
  validate :week_starts_on_monday

  private

  def week_starts_on_monday
    if week_start.present? && !week_start.monday?
      errors.add(:week_start, "deve ser uma segunda-feira")
    end
  end
end
