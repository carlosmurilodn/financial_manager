module SortableCollection
  private

  def sort_collection(collection, sort_map:, default_sort:, default_direction: "asc", sort: nil, direction: nil)
    requested_sort = sort.presence || params[:sort].to_s
    requested_direction = direction.presence || params[:direction]

    @sort = sort_map.key?(requested_sort.to_s) ? requested_sort.to_s : default_sort.to_s
    fallback_direction = default_direction == "desc" ? "desc" : "asc"
    @direction = requested_direction.present? ? (requested_direction == "desc" ? "desc" : "asc") : fallback_direction

    sorter = sort_map.fetch(@sort)
    sorted_collection = collection.sort_by do |record|
      normalize_sort_value(sorter.call(record))
    end

    @direction == "desc" ? sorted_collection.reverse : sorted_collection
  end

  def normalize_sort_value(value)
    case value
    when nil
      [ 1, "" ]
    when String
      [ 0, value.downcase ]
    when TrueClass, FalseClass
      [ 0, value ? 1 : 0 ]
    else
      [ 0, value ]
    end
  end
end
