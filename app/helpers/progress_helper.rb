module ProgressHelper
  def weekly_comparison_value(row, side)
    value = row.fetch(side)
    return "Sem registros" if value.nil?

    case row[:kind]
    when :weight
      "#{number_with_precision(value, precision: 2, separator: ',')} kg · #{pluralize(row.fetch(:"#{side}_count"), 'medição', 'medições')}"
    when :goals
      value.map { |goal| "#{goal.completed_count}/#{goal.target_count}" }.join(" · ")
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
    when :score
      "#{sign}#{pluralize(amount, 'ponto', 'pontos')}"
    when :wins
      "#{sign}#{pluralize(amount, 'registro', 'registros')}"
    end
  end
end
