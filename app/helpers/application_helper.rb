module ApplicationHelper
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
