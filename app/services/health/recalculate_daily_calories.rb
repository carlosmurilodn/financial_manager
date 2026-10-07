module Health
  class RecalculateDailyCalories
    def initialize(user:, dates: nil, from: nil)
      @user = user
      @dates = dates
      @from = from
    end

    def call
      @user.with_lock do
        @user.association(:health_profile).reset
        entries = @user.daily_calorie_entries
        entries = entries.where(occurred_on: @dates) unless @dates.nil?
        entries = entries.where("occurred_on >= ?", @from) if @from

        entries.find_each do |entry|
          entry.update!(DailyCalorieCalculation.new(
            user: @user,
            occurred_on: entry.occurred_on,
            consumed_calories: entry.consumed_calories
          ).call)
        end
      end
    end
  end
end
