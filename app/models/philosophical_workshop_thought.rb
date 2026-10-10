class PhilosophicalWorkshopThought < ApplicationRecord
  KINDS = { "reflection" => "Reflexão", "hypothesis" => "Hipótese", "conviction" => "Convicção" }.freeze
  STATUSES = { "developing" => "Em desenvolvimento", "consolidated" => "Consolidado", "revision" => "Em revisão" }.freeze

  belongs_to :user

  normalizes :title, with: ->(value) { value.to_s.strip }

  validates :title, presence: true, length: { maximum: 200 }
  validates :central_idea, presence: true
  validates :kind, inclusion: { in: KINDS.keys }
  validates :status, inclusion: { in: STATUSES.keys }

  def kind_label
    KINDS[kind]
  end

  def status_label
    STATUSES[status]
  end
end
