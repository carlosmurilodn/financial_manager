class WritingConflictPlot < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[writing_conflict_id writing_plot_id]

  LINK_ASSOCIATIONS = %i[writing_conflict writing_plot].freeze
  belongs_to :writing_book
  belongs_to :writing_conflict
  belongs_to :writing_plot
  include WritingBookLink
  validates :writing_plot_id, uniqueness: { scope: :writing_conflict_id }
end
