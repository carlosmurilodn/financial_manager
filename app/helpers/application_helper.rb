module ApplicationHelper
  def pagination_sequence(current_page, total_pages, window: 1)
    return [] if total_pages.to_i <= 1

    current_page = current_page.to_i
    total_pages = total_pages.to_i

    pages = [1, total_pages]
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
end
