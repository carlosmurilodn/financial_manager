class WritingConflictCharacter < ApplicationRecord
  LINK_ASSOCIATIONS = %i[writing_conflict writing_character].freeze
  belongs_to :writing_book
  belongs_to :writing_conflict
  belongs_to :writing_character
  include WritingBookLink
  validates :writing_character_id, uniqueness: { scope: :writing_conflict_id }
end
