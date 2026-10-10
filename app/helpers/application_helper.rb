module ApplicationHelper
  def mental_score_color(value, field: nil)
    return "blue" if value.nil?

    score = value.round(1)
    return field == :tension ? "green" : "red" if score <= 2
    return "yellow" if score <= 4

    field == :tension ? "red" : "green"
  end

  HEALTH_CONTROLLERS = %w[
    progress
    weight_entries
    health_weight_goals
    weekly_health_plans
    weekly_health_reviews
    self_knowledge
    health_journal_entries
    health_weekly_reflections
    weekly_wellbeings
    health_wins
    health_profiles
    physical_health
    daily_calorie_entries
    exercise_entries
    muscle_groups
    strength_exercise_catalogs
  ].freeze

  def personal_development_section?
    philosophical_workshop_section? || controller_name.in?(%w[personal_development writing_books writing_chapters writing_characters writing_relationships writing_plots writing_conflicts writing_locations writing_organizations writing_universe_rules writing_scenes writing_notes writing_narrative_contexts writing_timeline_events writing_publications writing_context_exports writing_github_syncs writing_statistics writing_productivity])
  end

  def philosophical_workshop_section?
    controller_name == "philosophical_workshop" || controller_name.start_with?("philosophical_workshop_")
  end

  def app_section_brand
    if personal_development_section?
      { title: "Projetos", icon: "school", footer_title: "Projetos", description: "Um espaço para organizar seus projetos.", labels: [] }
    elsif health_section?
      { title: "Saúde e Bem-Estar", icon: "self_improvement", footer_title: "Saúde e Bem-Estar", description: "Acompanhe sua saúde, cuide da rotina e reconheça suas conquistas.", labels: [ "Autoconhecimento", "Metas Semanais", "Acompanhamento Diário" ] }
    else
      { title: "Gerenciador Financeiro", icon: "account_balance_wallet", footer_title: "Dashboard Financeiro", description: "Controle receitas, despesas e previsoes em um unico painel.", labels: [ "Agenda Mensal", "Planejamento Anual", "Visao Consolidada" ] }
    end
  end

  def health_section?
    controller_name.in?(HEALTH_CONTROLLERS)
  end

  def health_nav_active?(item)
    case item
    when :progress
      controller_name == "progress"
    when :weight
      controller_name == "weight_entries"
    when :milestones
      controller_name == "health_weight_goals"
    when :basic_registries
      health_nav_active?(:profile) || health_nav_active?(:milestones) || health_nav_active?(:muscle_groups) || health_nav_active?(:strength_exercises)
    when :muscle_groups
      controller_name == "muscle_groups"
    when :strength_exercises
      controller_name == "strength_exercise_catalogs"
    when :daily
      controller_name == "health_journal_entries"
    when :weekly
      controller_name.in?(%w[health_weekly_reflections weekly_health_reviews])
    when :self_knowledge
      controller_name == "self_knowledge"
    when :beyond_scale
      controller_name.in?(%w[self_knowledge health_journal_entries health_weekly_reflections weekly_wellbeings weekly_health_reviews])
    when :goals
      controller_name.in?(%w[weekly_health_plans daily_calorie_entries])
    when :questions
      controller_name == "weekly_health_reviews"
    when :wins
      controller_name == "health_wins"
    when :profile
      controller_name == "health_profiles"
    when :nutrition
      controller_name == "physical_health" && action_name.in?(%w[nutrition nutrition_week toggle_nutrition_day new_nutrition_week create_nutrition_week edit_nutrition_week update_nutrition_week destroy_nutrition_week])
    when :exercise
      controller_name == "exercise_entries"
    else
      false
    end
  end

  def default_per_page
    ControllerPagination::DEFAULT_PER_PAGE
  end

  def per_page_options
    ControllerPagination::PER_PAGE_OPTIONS
  end

  def pagination_sequence(current_page, total_pages, window: 1)
    return [] if total_pages.to_i <= 1

    current_page = current_page.to_i
    total_pages = total_pages.to_i

    pages = [ 1, total_pages ]
    pages.concat((current_page - window..current_page + window).to_a)
    pages = pages.select { |page| page.between?(1, total_pages) }.uniq.sort

    sequence = []

    pages.each_with_index do |page, index|
      previous_page = pages[index - 1]
      sequence << :gap if previous_page && page - previous_page > 1
      sequence << page
    end

    sequence
  end

  def sortable_table_header(label, sort_key, align: nil)
    current_sort = (@sort || params[:sort]).to_s
    current_direction = (@direction || params[:direction]) == "desc" ? "desc" : "asc"
    active = current_sort == sort_key.to_s
    next_direction = active && current_direction == "asc" ? "desc" : "asc"
    icon = if active
      current_direction == "asc" ? "arrow_upward" : "arrow_downward"
    else
      "unfold_more"
    end

    link_to url_for(request.query_parameters.merge(sort: sort_key, direction: next_direction, page: 1)),
            class: [ "app-table-sort", ("is-active" if active), ("is-desc" if active && current_direction == "desc") ].compact.join(" "),
            aria: { label: "Ordenar por #{label}" },
            data: { turbo_prefetch: "false" } do
      safe_join([
        tag.span(label, class: "app-table-sort__label"),
        tag.span(icon, class: "material-symbols-rounded app-table-sort__icon", aria: { hidden: true })
      ])
    end
  end
end
