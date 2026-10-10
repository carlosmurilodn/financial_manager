class WritingBook < ApplicationRecord
  GENRES = {
    "fantasy" => "Fantasia", "science_fiction" => "Ficção científica",
    "romance" => "Romance", "thriller" => "Suspense", "mystery" => "Mistério",
    "crime" => "Policial", "horror" => "Terror", "drama" => "Drama",
    "adventure" => "Aventura", "historical_fiction" => "Ficção histórica",
    "contemporary" => "Literatura contemporânea", "other" => "Outros"
  }.freeze
  STATUSES = {
    "idea" => "Ideia", "planning" => "Planejamento", "writing" => "Em escrita",
    "revision" => "Em revisão", "completed" => "Concluído", "archived" => "Arquivado"
  }.freeze
  COVER_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_COVER_SIZE = 5.megabytes

  belongs_to :user
  has_one_attached :cover

  before_validation :normalize_fields
  validates :title, presence: true, length: { maximum: 200 }
  validates :subtitle, :author, :target_audience, length: { maximum: 200 }
  validates :genre, presence: true, inclusion: { in: GENRES.keys }
  validates :status, presence: true, inclusion: { in: STATUSES.keys }
  validate :valid_secondary_genres
  validate :valid_cover

  def genre_label
    GENRES[genre]
  end

  def status_label
    STATUSES[status]
  end

  private

  def normalize_fields
    self.title = title.to_s.strip
    self.author = author.to_s.strip.presence
    self.secondary_genres = Array(secondary_genres).reject(&:blank?).uniq - [ genre ]
  end

  def valid_secondary_genres
    errors.add(:secondary_genres, "contêm gêneros inválidos") if (secondary_genres - GENRES.keys).any?
  end

  def valid_cover
    return unless cover.attached?

    errors.add(:cover, "deve ser JPEG, PNG ou WebP") unless COVER_TYPES.include?(cover.content_type)
    errors.add(:cover, "deve ter no máximo 5 MB") if cover.byte_size > MAX_COVER_SIZE
  end
end
