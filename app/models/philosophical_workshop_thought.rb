class PhilosophicalWorkshopThought < ApplicationRecord
  KINDS = { "reflection" => "Reflexão", "hypothesis" => "Hipótese", "conviction" => "Convicção" }.freeze
  STATUSES = { "developing" => "Em desenvolvimento", "consolidated" => "Consolidado", "revision" => "Em revisão" }.freeze

  belongs_to :user
  belongs_to :source_insight, class_name: "PhilosophicalWorkshopInsight", optional: true, inverse_of: :derived_thoughts
  has_many :thought_questions, class_name: "PhilosophicalWorkshopThoughtQuestion", foreign_key: :thought_id, dependent: :destroy, inverse_of: :thought
  has_many :questions, through: :thought_questions

  normalizes :title, with: ->(value) { value.to_s.strip }

  validates :title, presence: true, length: { maximum: 200 }
  validates :central_idea, presence: true
  validates :kind, inclusion: { in: KINDS.keys }
  validates :status, inclusion: { in: STATUSES.keys }
  validate :source_insight_belongs_to_user

  def kind_label
    KINDS[kind]
  end

  def status_label
    STATUSES[status]
  end

  private

  def source_insight_belongs_to_user
    return unless source_insight

    errors.add(:source_insight, "deve pertencer ao mesmo usuário") if source_insight.user_id != user_id
  end
end
