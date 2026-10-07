FactoryBot.define do
  factory :health_journal_entry do
    association :user
    entry_date { Date.new(2026, 10, 7) }
    main_thought { "Uma conversa importante" }
  end

  factory :health_weekly_reflection do
    association :user
    week_start { Date.new(2026, 10, 5) }
    recurring_patterns { "Precisei de descanso" }
  end

  factory :legacy_health_review, class: "WeeklyHealthReview" do
    association :user
    week_start { Date.new(2026, 10, 5) }
    review_kind { "weekly" }
    worked_well { "Conversa antiga" }
  end

  factory :legacy_wellbeing, class: "WeeklyWellbeing" do
    association :user
    week_start { Date.new(2026, 10, 5) }
    mood { 3 }
    energy { 4 }
    routine_satisfaction { 2 }
    notes { "Observação histórica" }
  end
end
