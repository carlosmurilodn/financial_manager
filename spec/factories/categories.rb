FactoryBot.define do
  factory :category do
    association :user
    sequence(:name) { |number| "Categoria #{number}" }
    color { Category::COLOR_PALETTE.values.first }
  end
end
