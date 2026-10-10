class PhilosophicalWorkshopConceptPhilosopher < ApplicationRecord
  belongs_to :concept, class_name: "PhilosophicalWorkshopConcept", inverse_of: :concept_philosophers
  belongs_to :philosopher, class_name: "PhilosophicalWorkshopPhilosopher", inverse_of: :concept_philosophers

  validates :philosopher_id, uniqueness: { scope: :concept_id }
  validate :same_user

  private

  def same_user
    return unless concept && philosopher

    errors.add(:philosopher, "deve pertencer ao mesmo usuário") if concept.user_id != philosopher.user_id
  end
end
