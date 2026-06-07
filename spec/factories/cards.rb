FactoryBot.define do
  factory :card do
    association :user
    sequence(:name) { |number| "Cartao #{number}" }
    total_limit { 5_000 }
    due_day { 10 }
    closing_day { 5 }
    color { Category::COLOR_PALETTE.values.first }
  end
end
