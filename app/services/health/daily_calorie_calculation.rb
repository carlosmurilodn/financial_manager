module Health
  class DailyCalorieCalculation
    TRAINING_WORDS = %w[treinar treino musculacao funcional].freeze
    WALKING_WORDS = %w[caminhar caminhada].freeze
    FACTORS = {
      [ false, false ] => BigDecimal("1.2"),
      [ false, true ] => BigDecimal("1.375"),
      [ true, false ] => BigDecimal("1.55"),
      [ true, true ] => BigDecimal("1.725")
    }.freeze

    def initialize(user:, occurred_on:, consumed_calories:)
      @user = user
      @date = occurred_on
      @consumed_calories = consumed_calories
    end

    def call
      snapshot = activity_snapshot.merge(
        reference_weight_kg: nil, reference_weight_date: nil,
        height_cm: nil, birth_date: nil, age: nil, formula_sex: nil,
        bmr: nil, tdee: nil, calorie_deficit: nil, calculated_at: Time.current
      )
      profile = @user.health_profile
      weight = @user.weight_entries.where("measured_on <= ?", @date).order(measured_on: :desc).first
      snapshot.merge!(reference_weight_kg: weight.weight_kg, reference_weight_date: weight.measured_on) if weight
      return pending(snapshot, "missing_profile") unless profile

      snapshot.merge!(height_cm: profile.height_cm, birth_date: profile.birth_date, formula_sex: profile.formula_sex)
      return pending(snapshot, "invalid_profile") unless profile.valid? && profile.birth_date <= @date

      snapshot[:age] = age_on(profile.birth_date)
      return pending(snapshot, "missing_weight") unless weight

      adjustment = profile.formula_sex == "male" ? 5 : -161
      bmr = 10 * weight.weight_kg + BigDecimal("6.25") * profile.height_cm - 5 * snapshot[:age] + adjustment
      return pending(snapshot, "invalid_profile") unless bmr.positive?

      snapshot[:bmr] = bmr
      snapshot[:tdee] = bmr * snapshot[:activity_factor]
      return pending(snapshot, "missing_consumption") if @consumed_calories.nil?

      snapshot[:calorie_deficit] = snapshot[:tdee] - @consumed_calories
      snapshot[:calculation_status] = "calculated"
      snapshot
    end

    private

    def activity_snapshot
      exercise_types = @user.exercise_entries
        .joins(:exercise_items)
        .where(performed_on: @date)
        .distinct
        .pluck("exercise_items.exercise_type")

      trained = exercise_types.any? { |type| %w[training functional].include?(type) }
      walked = exercise_types.include?("ergometry")
      { trained: trained, walked: walked, activity_factor: FACTORS.fetch([ trained, walked ]) }
    end

    def age_on(birth_date)
      birthday_reached = ([ @date.month, @date.day ] <=> [ birth_date.month, birth_date.day ]) >= 0
      @date.year - birth_date.year - (birthday_reached ? 0 : 1)
    end

    def pending(snapshot, status)
      snapshot.merge(calculation_status: status)
    end
  end
end
