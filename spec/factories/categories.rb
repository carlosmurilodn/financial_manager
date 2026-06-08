FactoryBot.define do
  factory :category do
    sequence(:name) { |number| "Categoria #{number}" }
    color { Category::COLOR_PALETTE.values.first }
  end
end
