require "rails_helper"

RSpec.describe HealthWeeklyReflection, type: :model do
  it "permite revisão parcial" do
    expect(build(:health_weekly_reflection, recurring_patterns: nil, routine_satisfaction: 4)).to be_valid
    expect(build(:health_weekly_reflection, recurring_patterns: nil, weekly_needs: ["Tempo sozinho"])).to be_valid
  end

  it "exige semana na segunda-feira" do
    expect(build(:health_weekly_reflection, week_start: nil)).not_to be_valid
    expect(build(:health_weekly_reflection, week_start: Date.new(2026, 10, 6))).not_to be_valid
  end

  it "valida limites e escala" do
    expect(build(:health_weekly_reflection, routine_satisfaction: 6)).not_to be_valid
    expect(build(:health_weekly_reflection, weekly_learning: "a" * 2001)).not_to be_valid
    expect(build(:health_weekly_reflection, recurring_patterns: nil)).not_to be_valid
  end

  it "impede duplicação de semana por usuário" do
    week = create(:health_weekly_reflection)
    expect(build(:health_weekly_reflection, user: week.user)).not_to be_valid
  end
end
