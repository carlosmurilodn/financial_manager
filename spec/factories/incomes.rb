FactoryBot.define do
  factory :income do
    association :user
    category { association(:category, user: user) }
    description { "Salario" }
    amount { 3_000 }
    date { Date.current }
    balance_month { Date.current.beginning_of_month }
    paid { true }
  end
end
