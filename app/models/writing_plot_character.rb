class WritingPlotCharacter < ApplicationRecord
  LINK_ASSOCIATIONS = %i[writing_plot writing_character].freeze
  belongs_to :writing_book
  belongs_to :writing_plot
  belongs_to :writing_character
  include WritingBookLink
  validates :writing_character_id, uniqueness: { scope: :writing_plot_id }
end
