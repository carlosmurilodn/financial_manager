class WritingPlotCharacter < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[writing_plot_id writing_character_id]

  LINK_ASSOCIATIONS = %i[writing_plot writing_character].freeze
  belongs_to :writing_book
  belongs_to :writing_plot
  belongs_to :writing_character
  include WritingBookLink
  validates :writing_character_id, uniqueness: { scope: :writing_plot_id }
end
