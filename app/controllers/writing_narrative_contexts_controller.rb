class WritingNarrativeContextsController < ApplicationController
  KINDS = {
    "characters" => [ WritingCharacter, "Personagens" ], "plots" => [ WritingPlot, "Tramas" ],
    "conflicts" => [ WritingConflict, "Conflitos" ], "locations" => [ WritingLocation, "Cenários" ],
    "organizations" => [ WritingOrganization, "Organizações" ], "notes" => [ WritingNote, "Notas e Ideias" ],
    "timeline" => [ WritingTimelineEvent, "Linha do Tempo" ]
  }.freeze
  before_action :set_context

  def show
    if params[:record_id].present?
      record = records_scope.find(params[:record_id])
      return render json: { record: serialize_details(record) }
    end
    linked_ids = association_scope.pluck("#{target_association}_id")
    scope = records_scope
    query = params[:query].to_s.strip
    if query.present?
      pattern = "%#{@model.sanitize_sql_like(query)}%"
      scope = if @model == WritingNote
        scope.where("title ILIKE ? OR description ILIKE ?", pattern, pattern)
      elsif @model == WritingCharacter
        scope.where("concat_ws(' ', name, surname, nicknames) ILIKE ?", pattern)
      else
        scope.where(@model.arel_table[name_field].matches(pattern, nil, false))
      end
    elsif params[:all] != "1"
      scope = if @model == WritingNote
        @owner.related_notes
      elsif @model == WritingTimelineEvent
        @owner.related_timeline_events
      else
        scope.where(id: linked_ids)
      end
    end
    records = scope.order(name_field, :id).limit(51).to_a
    render json: { records: records.first(50).map { |record| { id: record.id, name: record_name(record), summary: record_summary(record), associated: linked_ids.include?(record.id) } }, more: records.size > 50 }
  end

  def create
    record = records_scope.find(params.require(:record_id))
    attributes = @owner.narrative_owner_attributes.merge(target_association => record)
    @book.with_lock { link_scope.find_or_create_by!(attributes) }
    render json: { message: "Associação adicionada. O manuscrito foi preservado." }
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_content
  end

  def destroy
    record = records_scope.find(params.require(:record_id))
    association_scope.find_by!(target_association => record).destroy!
    render json: { message: "Associação removida. O cadastro e o manuscrito foram preservados." }
  end

  private

  def set_context
    @book = current_user.writing_books.find(params[:writing_book_id])
    raise ActiveRecord::RecordNotFound unless [ params[:chapter_id], params[:scene_id] ].count(&:present?) == 1

    @owner = params[:scene_id].present? ? @book.writing_scenes.find(params[:scene_id]) : @book.writing_chapters.find(params[:chapter_id])
    @kind = params[:kind].presence || "characters"
    @model = KINDS.fetch(@kind) { raise ActiveRecord::RecordNotFound }.first
    response.headers["Cache-Control"] = "private, no-store"
  end

  def target_association
    @model.model_name.singular.to_sym
  end

  def name_field
    @model == WritingCharacter ? :name : @model::NAME_FIELD
  end

  def records_scope
    @book.public_send(@model.model_name.route_key)
  end

  def link_scope
    return @book.writing_timeline_links if @model == WritingTimelineEvent

    @model == WritingNote ? @book.writing_note_links : @book.writing_narrative_associations
  end

  def association_scope
    link_scope.where(@owner.narrative_owner_attributes)
  end

  def record_name(record)
    record.respond_to?(:full_name) ? record.full_name : record.display_name
  end

  def record_summary(record)
    return "#{record.role_label} · #{record.profession.presence || record.status_label}" if record.is_a?(WritingCharacter)

    return "#{helpers.timeline_temporal_label(record)} · #{WritingTimelineEvent::OPTIONS[:status][record.status]}" if record.is_a?(WritingTimelineEvent)

    record.class::OPTIONS.map { |field, options| options[record.public_send(field)] }.compact.join(" · ")
  end

  def serialize_details(record)
    fields = record.is_a?(WritingCharacter) ? WritingCharacter::PROFILE_SECTIONS.values.reduce({}, :merge).merge(nicknames: "Apelidos") : record.class::FIELDS.except(record.class::NAME_FIELD)
    details = fields.filter_map do |field, label|
      value = record.public_send(field)
      next if value.blank?

      value = record.class::OPTIONS[field]&.fetch(value, value) if record.class.const_defined?(:OPTIONS, false)
      { label: label, value: value }
    end
    if record.is_a?(WritingTimelineEvent)
      details << { label: "Quando", value: helpers.timeline_temporal_label(record) }
      details << { label: "Acontecimento de referência", value: record.reference_event.title } if record.reference_event
      links = record.writing_timeline_links.includes(*WritingTimelineLink::DETAIL_ASSOCIATIONS)
      WritingTimelineLink::TARGETS.each do |target, label|
        names = links.filter_map { |link| helpers.timeline_target_label(link.public_send(target)) if link.public_send(target) }
        details << { label: label, value: names.join(" · ") } if names.any?
      end
    end
    if record.is_a?(WritingNote)
      details += [ { label: "Criado em", value: I18n.l(record.created_at.to_date) }, { label: "Atualizado em", value: I18n.l(record.updated_at.to_date) } ]
    end
    { id: record.id, name: record_name(record), summary: record_summary(record), details: details }
  end
end
