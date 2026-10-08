module Health
  module PhysicalActivities
    EXERCISE_CATEGORIES = { "training" => "Musculação", "functional" => "Treino Funcional", "walking" => "Caminhada" }.freeze
    CATEGORIES = { "nutrition" => "Alimentação" }.merge(EXERCISE_CATEGORIES).freeze
    GOAL_NAMES = {
      "nutrition" => %w[alimentacao],
      "training" => %w[musculacao treino treinar],
      "functional" => %w[treino-funcional funcional],
      "walking" => %w[caminhada caminhar]
    }.transform_values(&:freeze).freeze

    def self.goal_for(plan, type)
      names = GOAL_NAMES.fetch(type, [])
      plan&.weekly_health_goals&.find { |goal| names.include?(goal.name.parameterize) }
    end
  end
end
