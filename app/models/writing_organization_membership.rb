class WritingOrganizationMembership < ApplicationRecord
  LINK_ASSOCIATIONS = %i[writing_organization writing_character].freeze
  belongs_to :writing_book
  belongs_to :writing_organization
  belongs_to :writing_character
  include WritingBookLink
  validates :writing_character_id, uniqueness: { scope: :writing_organization_id }
end
