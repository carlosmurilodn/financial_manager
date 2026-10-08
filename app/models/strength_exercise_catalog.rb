class StrengthExerciseCatalog < ApplicationRecord
  belongs_to :user
  belongs_to :muscle_group

  validates :name, presence: true, length: { maximum: 120 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :muscle_group_belongs_to_user

  scope :active, -> { where(active: true) }
  scope :ordered, -> { joins(:muscle_group).order("muscle_groups.position ASC", "muscle_groups.name ASC", :position, :name, :id) }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip
  end

  def muscle_group_belongs_to_user
    return if muscle_group.blank? || user.blank?
    return if muscle_group.user_id == user_id

    errors.add(:muscle_group, "deve pertencer ao usuário")
  end
end
