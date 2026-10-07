module Health
  class SaveDailyCalories
    def initialize(user:, occurred_on:, consumed_calories:)
      @user = user
      @occurred_on = occurred_on.is_a?(Date) ? occurred_on : Date.iso8601(occurred_on.to_s)
      @consumed_calories = consumed_calories
    end

    def call
      @user.with_lock do
        entry = @user.daily_calorie_entries.find_or_initialize_by(occurred_on: @occurred_on)
        entry.consumed_calories = normalized_consumption
        entry.validate!
        entry.assign_attributes(DailyCalorieCalculation.new(
          user: @user,
          occurred_on: entry.occurred_on,
          consumed_calories: entry.consumed_calories
        ).call)
        entry.save!
        entry
      end
    end

    private

    def normalized_consumption
      return nil if @consumed_calories.nil?
      return @consumed_calories unless @consumed_calories.is_a?(String)

      @consumed_calories.strip.tr(",", ".").presence
    end
  end
end
