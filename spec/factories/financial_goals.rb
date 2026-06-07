FactoryBot.define do
  factory :financial_goal do
    association :user
    association :category
    description { "Reserva de emergencia" }
    target_amount { 10_000 }
    current_amount { 1_000 }
    due_date { 6.months.from_now.to_date }
    status { :in_progress }
    priority { :medium }
    color { Category::COLOR_PALETTE.values.first }
  end
end
