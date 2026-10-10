FactoryBot.define do
  factory :writing_book do
    association :user
    sequence(:title) { |n| "Livro #{n}" }
    genre { "fantasy" }
    status { "writing" }
  end
end
