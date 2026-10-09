class WeeklyHealthGoal < ApplicationRecord
  LEGACY_EXERCISE_NAMES = %w[musculacao treino treinar treino-funcional funcional caminhada caminhar ergometria].freeze

  belongs_to :weekly_health_plan, inverse_of: :weekly_health_goals
  has_many :weekly_health_goal_days, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :target_count, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10000 }
  validates :completed_count, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10000 }
  validates :notes, length: { maximum: 500 }
  validate :exercise_uses_daily_entries

  def progress_percent
    return 0 unless target_count.to_i.positive?

    (completed_count.to_f / target_count * 100)
  end

  def completed_on?(date)
    completed_day_dates.include?(date)
  end

  def sync_completed_count!
    update!(completed_count: weekly_health_goal_days.completed.count)
  end

  private

  def exercise_uses_daily_entries
    return unless LEGACY_EXERCISE_NAMES.include?(name.to_s.parameterize)

    errors.add(:name, "não pode ser usado em metas semanais; registre o exercício em Exercícios diários")
  end

  def completed_day_dates
    @completed_day_dates ||= weekly_health_goal_days.select(&:completed?).map(&:occurred_on).to_set
  end
end
