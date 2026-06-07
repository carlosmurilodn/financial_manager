FactoryBot.define do
  factory :expense do
    association :user
    category { association(:category, user: user) }
    description { "Mercado" }
    amount { 150 }
    date { Date.current }
    balance_month { Date.current.beginning_of_month }
    payment_method { :pix }
    paid { false }
    installments_count { 1 }
    current_installment { 1 }

    trait :card_payment do
      card { association(:card, user: user) }
      payment_method { :credito_a_vista }
    end

    trait :paid do
      paid { true }
    end

    trait :refund do
      card { association(:card, user: user) }
      payment_method { :estorno_cartao }
    end
  end
end
