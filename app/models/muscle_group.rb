class MuscleGroup < ApplicationRecord
  belongs_to :user
  has_many :strength_exercise_catalogs, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name, :id) }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip
  end
end
