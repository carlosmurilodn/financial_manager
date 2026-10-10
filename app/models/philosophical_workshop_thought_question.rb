class PhilosophicalWorkshopThoughtQuestion < ApplicationRecord
  belongs_to :thought, class_name: "PhilosophicalWorkshopThought", inverse_of: :thought_questions
  belongs_to :question, class_name: "PhilosophicalWorkshopQuestion", inverse_of: :thought_questions

  validates :question_id, uniqueness: { scope: :thought_id }
  validate :same_user

  private

  def same_user
    return unless thought && question

    errors.add(:question, "deve pertencer ao mesmo usuário") if thought.user_id != question.user_id
  end
end
