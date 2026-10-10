class WritingGithubSync < ApplicationRecord
  STATUSES = { "never" => "Nunca sincronizado", "processing" => "Sincronização em andamento", "succeeded" => "Concluída", "failed" => "Não concluída" }.freeze

  belongs_to :writing_book
  validates :writing_book_id, uniqueness: true
  validates :status, inclusion: { in: STATUSES.keys }
  validates :created_count, :updated_count, :unchanged_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def status_label
    STATUSES.fetch(status)
  end
end
