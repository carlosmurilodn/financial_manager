class HealthJournalEntry < ApplicationRecord
  include HealthPersonalRecord
  TEXT_FIELDS = %i[main_thought meaningful_event emotions positive_moment needs_notes reflection_answer notes].freeze
  METRIC_FIELDS = %i[mood energy tension].freeze
  NEEDS_FIELD = :needs
  validates :entry_date, presence: true, uniqueness: { scope: :user_id }
  validates(*METRIC_FIELDS, numericality: { only_integer: true, in: 1..5 }, allow_nil: true)
  validates(*TEXT_FIELDS, length: { maximum: 2000 })
  validates :reflection_prompt_key, inclusion: { in: Health::SelfKnowledgeContent::ROTATING.keys }, allow_nil: true
  before_validation :choose_reflection_prompt

  def needs=(values)
    super(values.is_a?(Array) ? values.reject(&:blank?).uniq : values)
  end

  def reference_date
    entry_date
  end

  def reflection_prompt
    key = reflection_prompt_key || prompt_key_for_date
    Health::SelfKnowledgeContent::ROTATING.fetch(key)
  end

  def prompt_key_for_date
    Health::SelfKnowledgeContent::ROTATING.keys[(entry_date || Date.current).jd % Health::SelfKnowledgeContent::ROTATING.size]
  end

  private

  def choose_reflection_prompt
    self.reflection_prompt_key = prompt_key_for_date if entry_date && (reflection_prompt_key.blank? || will_save_change_to_entry_date?)
  end
end
