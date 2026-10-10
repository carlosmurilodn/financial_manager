class WritingConflictPlot < ApplicationRecord
  LINK_ASSOCIATIONS = %i[writing_conflict writing_plot].freeze
  belongs_to :writing_book
  belongs_to :writing_conflict
  belongs_to :writing_plot
  include WritingBookLink
  validates :writing_plot_id, uniqueness: { scope: :writing_conflict_id }
end
