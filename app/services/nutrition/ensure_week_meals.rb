module Nutrition
  class EnsureWeekMeals
    DEFAULT_NAMES = [ "Café da manhã", "Almoço", "Lanche", "Jantar", "Ceia" ].freeze

    def initialize(user:, week_start:)
      @user = user
      @week_start = week_start
    end

    def call
      @user.with_lock do
        existing = @user.nutrition_meals.where(occurred_on: @week_start..@week_start + 6.days)
          .pluck(:occurred_on, :name)
        7.times do |offset|
          date = @week_start + offset.days
          DEFAULT_NAMES.each do |name|
            next if existing.include?([ date, name ])

            @user.nutrition_meals.create!(occurred_on: date, name: name)
          end
        end
      end
    end
  end
end
