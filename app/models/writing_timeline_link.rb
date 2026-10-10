class WritingTimelineLink < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[writing_timeline_event_id writing_character_id writing_location_id writing_plot_id writing_conflict_id writing_chapter_id writing_scene_id]

  TARGETS = {
    writing_character: "Personagens", writing_location: "Locais", writing_plot: "Tramas",
    writing_conflict: "Conflitos", writing_chapter: "Capítulos", writing_scene: "Cenas"
  }.freeze
  DETAIL_ASSOCIATIONS = [ *TARGETS.keys, { writing_scene: :writing_chapter } ].freeze

  belongs_to :writing_book
  belongs_to :writing_timeline_event
  TARGETS.each_key { |target| belongs_to target, optional: true }
  validate :valid_timeline_link

  private

  def valid_timeline_link
    targets = TARGETS.keys.select { |target| public_send("#{target}_id").present? }
    errors.add(:base, "Selecione exatamente um vínculo para o acontecimento.") unless targets.one?
    ([ :writing_timeline_event ] + targets).each do |target|
      record = public_send(target)
      errors.add(target, "deve pertencer ao mesmo livro") unless record && record.writing_book_id == writing_book_id
    end
    return unless targets.one?

    field = "#{targets.first}_id"
    scope = self.class.where(writing_timeline_event_id: writing_timeline_event_id, field => public_send(field))
    errors.add(:base, "Vínculo já cadastrado.") if scope.where.not(id: id).exists?
  end
end
