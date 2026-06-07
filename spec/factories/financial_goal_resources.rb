FactoryBot.define do
  factory :financial_goal_resource do
    association :financial_goal
    resource_type { :own_resource }
    description { "Poupanca" }
    amount { 500 }
    include_in_total { true }

    trait :external_resource do
      resource_type { :external_resource }
      description { "FGTS" }
    end

    trait :credit_limit do
      transient do
        user { financial_goal.user }
      end

      resource_type { :credit_limit }
      description { "" }
      amount { 0 }
      source { association(:card, user: user) }
    end
  end
end
