class WritingChapter < ApplicationRecord
  belongs_to :writing_book, touch: true
  has_many :writing_scenes, dependent: :destroy
  include WritingElementOwner

  def display_name
    title
  end

  normalizes :title, with: ->(value) { value.to_s.strip }
  validates :title, presence: true, length: { maximum: 200 }
  validates :document_version, inclusion: { in: [ 1 ] }
  validate :valid_literary_document

  scope :ordered, -> { order(:position, :created_at, :id) }

  private

  def valid_literary_document
    errors.add(:content, "possui estrutura ou formatação inválida") unless Writing::Document.new(content).valid?
  end
end
