class MuscleGroup < ApplicationRecord
  belongs_to :user
  has_many :strength_exercise_catalogs, dependent: :restrict_with_error
  has_one_attached :example_image

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :example_image_must_be_image

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name, :id) }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip
  end

  def example_image_must_be_image
    return unless example_image.attached?
    return if example_image.content_type.to_s.start_with?("image/")

    errors.add(:example_image, "deve ser uma imagem")
  end
end
