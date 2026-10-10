class WritingGithubSync < ApplicationRecord
  STATUSES = { "never" => "Nunca sincronizado", "processing" => "Sincronização em andamento", "succeeded" => "Concluída", "failed" => "Não concluída" }.freeze

  belongs_to :writing_book
  validates :writing_book_id, uniqueness: true
  validates :status, inclusion: { in: STATUSES.keys }
  validates :created_count, :updated_count, :unchanged_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def status_label
    STATUSES.fetch(status)
  end

  def next_attempt_at
    [ scheduled_at, retry_at ].compact.max
  end

  def actively_processing?
    status == "processing" && last_attempt_at.present? && last_attempt_at > 2.minutes.ago
  end

  def scheduling_label
    return "Sincronizando com GitHub" if actively_processing?
    return "Falha na sincronização" if status == "failed" || (status == "processing" && !actively_processing?)
    return "Sincronização pendente" if pending_changes?
    return "GitHub sincronizado" if last_success_at.present?

    "Nunca sincronizado"
  end
end
