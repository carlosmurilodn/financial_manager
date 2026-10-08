class StrengthExerciseLog < ApplicationRecord
  belongs_to :exercise_item, inverse_of: :strength_exercise_logs
  belongs_to :muscle_group
  belongs_to :strength_exercise_catalog

  validates :sets, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validate :catalog_belongs_to_group
  validate :records_belong_to_entry_user

  private

  def catalog_belongs_to_group
    return if strength_exercise_catalog.blank? || muscle_group.blank?
    return if strength_exercise_catalog.muscle_group_id == muscle_group_id

    errors.add(:strength_exercise_catalog, "deve pertencer ao grupo muscular")
  end

  def records_belong_to_entry_user
    return if exercise_item.blank? || exercise_item.exercise_entry.blank?
    return if muscle_group.blank? || strength_exercise_catalog.blank?

    user_id = exercise_item.exercise_entry.user_id
    errors.add(:muscle_group, "deve pertencer ao usuário") if muscle_group.user_id != user_id
    errors.add(:strength_exercise_catalog, "deve pertencer ao usuário") if strength_exercise_catalog.user_id != user_id
  end
end
