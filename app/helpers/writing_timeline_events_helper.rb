module WritingTimelineEventsHelper
  def timeline_action_label(icon, label)
    parts = [ tag.span(icon, class: "material-symbols-rounded", aria: { hidden: true }) ]
    parts << tag.span(label, class: "writing-record-action__label") if label.present?
    safe_join(parts)
  end

  def timeline_temporal_label(event)
    label = case event.date_mode
    when "exact" then event.occurred_on ? l(event.occurred_on) : "Data não informada"
    when "approximate" then "Aproximada: #{event.temporal_reference}"
    when "relative" then "Relativa: #{event.temporal_reference}"
    else "Sem definição temporal"
    end
    event.occurred_at ? "#{label} · #{event.occurred_at.strftime('%H:%M')}" : label
  end

  def timeline_target_label(record)
    return record.full_name if record.respond_to?(:full_name)
    return "#{record.writing_chapter.title} · #{record.title}" if record.is_a?(WritingScene)

    record.display_name
  end

  def timeline_links(event)
    event.writing_timeline_links.filter_map do |link|
      WritingTimelineLink::TARGETS.keys.filter_map { |target| link.public_send(target) }.first
    end
  end
end
