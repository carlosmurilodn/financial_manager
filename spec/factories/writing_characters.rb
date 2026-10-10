FactoryBot.define do
  factory :writing_character do
    association :writing_book
    sequence(:name) { |n| "Personagem #{n}" }
  end
end
