module HealthFiltersHelper
  def health_combined_sort_options(fields)
    fields.flat_map do |field, label|
      directions = %w[name category].include?(field) ? [ "A–Z", "Z–A" ] : [ "Menor primeiro", "Maior primeiro" ]
      [ [ "#{label} · #{directions[0]}", "#{field}:asc" ], [ "#{label} · #{directions[1]}", "#{field}:desc" ] ]
    end
  end
end
