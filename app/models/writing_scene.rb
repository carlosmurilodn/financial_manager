class WritingScene < ApplicationRecord
  belongs_to :writing_book
  belongs_to :writing_chapter
  normalizes :title, with: ->(value) { value.to_s.strip }
  validates :title, presence: true, length: { maximum: 200 }
  validates :document_version, inclusion: { in: [ 1 ] }
  validate :valid_scene_document
  validate :chapter_from_same_book
  scope :ordered, -> { order(:position, :created_at, :id) }
  include WritingElementOwner

  def display_name
    title
  end

  private

  def valid_scene_document
    errors.add(:content, "possui estrutura ou formatação inválida") unless Writing::Document.new(content).valid?
  end

  def chapter_from_same_book
    errors.add(:writing_chapter, "deve pertencer ao mesmo livro") if writing_chapter && writing_chapter.writing_book_id != writing_book_id
  end
end
