module ProgressHelper
  def progress_activity_status(state)
    case state
    when "deficit" then { label: "Déficit calórico — meta atingida", icon: "check", css: "is-done" }
    when "surplus" then { label: "Superávit calórico — meta não atingida", icon: "close", css: "is-not-done" }
    when "balanced" then { label: "Equilíbrio calórico — sem déficit", icon: "remove", css: "is-unselected" }
    when "pending" then { label: "Dados insuficientes para calcular o saldo calórico", icon: "remove", css: "is-unselected" }
    when "full" then { label: "Segui a Dieta Totalmente", icon: "check", css: "is-done" }
    when "completed" then { label: "Realizado", icon: "check", css: "is-done" }
    when "partial" then { label: "Segui a Dieta Parcialmente", icon: "remove", css: "is-partial" }
    when "none" then { label: "Não Segui a Dieta", icon: "close", css: "is-not-done" }
    when "not_completed" then { label: "Não Realizado", icon: "close", css: "is-not-done" }
    else { label: "Sem registro", icon: "remove", css: "is-unselected" }
    end
  end

  def weekly_comparison_value(row, side)
    value = row.fetch(side)
    return "Sem registros" if value.nil?

    case row[:kind]
    when :weight
      "#{number_with_precision(value, precision: 2, separator: ',')} kg · #{pluralize(row.fetch(:"#{side}_count"), 'medição', 'medições')}"
    when :goals
      value.map { |goal| "#{goal.completed_count}/#{goal.target_count}" }.join(" · ")
    when :exercise_days, :nutrition_days
      pluralize(value, "dia", "dias")
    when :score
      "#{value}/5"
    when :wins
      pluralize(value, "registro", "registros")
    end
  end

  def weekly_comparison_delta(row)
    delta = row[:delta]
    return "Sem comparação" if delta.nil?
    return "Sem alteração" if delta.zero?

    sign = delta.positive? ? "+" : "−"
    amount = delta.abs
    case row[:kind]
    when :weight
      "#{sign}#{number_with_precision(amount, precision: 2, separator: ',')} kg"
    when :goals
      "#{sign}#{pluralize(amount, 'realizado', 'realizados')}"
    when :exercise_days, :nutrition_days
      "#{sign}#{pluralize(amount, 'dia', 'dias')}"
    when :score
      "#{sign}#{pluralize(amount, 'ponto', 'pontos')}"
    when :wins
      "#{sign}#{pluralize(amount, 'registro', 'registros')}"
    end
  end

  def progress_metric(value, unit: "kcal", signed: false)
    return "Sem dados" if value.nil?

    prefix = signed && value.positive? ? "+" : ""
    "#{prefix}#{number_with_precision(value, precision: 2, strip_insignificant_zeros: true, separator: ',', delimiter: '.')} #{unit}"
  end
end
