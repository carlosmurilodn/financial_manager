class WritingConflictCharacter < ApplicationRecord
  include WritingGithubTracking
  self.github_export_fields = %i[writing_conflict_id writing_character_id]

  LINK_ASSOCIATIONS = %i[writing_conflict writing_character].freeze
  belongs_to :writing_book
  belongs_to :writing_conflict
  belongs_to :writing_character
  include WritingBookLink
  validates :writing_character_id, uniqueness: { scope: :writing_conflict_id }
end
