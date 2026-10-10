class WritingTimelineEventsController < ApplicationController
  before_action :set_book
  before_action :set_event, only: %i[show edit update destroy reorder]

  def index
    scope = @book.writing_timeline_events
    @query = params[:query].to_s.strip
    scope = scope.where("title ILIKE ?", "%#{WritingTimelineEvent.sanitize_sql_like(@query)}%") if @query.present?
    %i[kind status].each { |field| scope = scope.where(field => params[field]) if params[field].present? }
    if params[:character_id].present?
      @book.writing_characters.find(params[:character_id])
      ids = @book.writing_timeline_links.where(writing_character_id: params[:character_id]).select(:writing_timeline_event_id)
      scope = scope.where(id: ids)
    end
    @order = params[:order] == "narrative" ? "narrative" : "chronological"
    @events = scope.includes(:reference_event, writing_timeline_links: WritingTimelineLink::DETAIL_ASSOCIATIONS).to_a
    @groups = Writing::Timeline.new(@book, @events).groups(@order)
    @reordering_enabled = @query.blank? && %i[kind status character_id].all? { |field| params[field].blank? }
    @manual_ids = @book.writing_timeline_events.where.not(date_mode: "exact").manual_order.pluck(:id)
  end

  def show
    @links = @event.writing_timeline_links.includes(*WritingTimelineLink::DETAIL_ASSOCIATIONS)
  end

  def new
    @event = @book.writing_timeline_events.new
    render :form
  end

  def edit
    render :form
  end

  def create
    @event = @book.writing_timeline_events.new
    save_event
  end

  def update
    save_event
  end

  def destroy
    @book.with_lock { @event.destroy! }
    redirect_to writing_book_writing_timeline_events_path(@book), notice: "Acontecimento excluído. Manuscrito e registros vinculados preservados.", status: :see_other
  end

  def reorder
    unless params[:direction].in?(%w[up down])
      return head :bad_request
    end
    @book.with_lock do
      @event.reload
      unless @event.date_mode == "exact"
        events = @book.writing_timeline_events.where.not(date_mode: "exact").manual_order.to_a
        index = events.index { |event| event.id == @event.id }
        destination = index + (params[:direction] == "up" ? -1 : 1)
        if destination.between?(0, events.length - 1)
          events[index], events[destination] = events[destination], events[index]
          events.each_with_index { |event, position| event.update_columns(position: position) }
        end
      end
    end
    redirect_to writing_book_writing_timeline_events_path(@book), notice: "Ordem cronológica manual preservada.", status: :see_other
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def set_event
    @event = @book.writing_timeline_events.find(params[:id])
  end

  def event_params
    params.require(:writing_timeline_event).permit(:title, :description, :kind, :status, :date_mode, :occurred_on, :occurred_at, :temporal_reference, :reference_event_id)
  end

  def selected_targets
    raw = params.require(:writing_timeline_event).permit(links: WritingTimelineLink::TARGETS.keys.to_h { |target| [ target, [] ] })[:links] || {}
    raw.to_h.flat_map do |target, ids|
      @book.public_send(target.to_s.pluralize).find(ids.reject(&:blank?).uniq).uniq(&:id).map { |record| [ target.to_sym, record ] }
    end
  end

  def save_event
    saved = false
    @book.with_lock do
      @event.assign_attributes(event_params)
      @targets = selected_targets
      @event.position = (@book.writing_timeline_events.maximum(:position) || -1) + 1 if @event.new_record?
      saved = @event.save
      if saved
        @event.writing_timeline_links.destroy_all
        @targets.each { |target, record| @event.writing_timeline_links.create!(writing_book: @book, target => record) }
      else
        raise ActiveRecord::Rollback
      end
    end
    if saved
      redirect_to [ @book, @event ], notice: "Acontecimento salvo. O manuscrito foi preservado.", status: :see_other
    else
      render :form, status: :unprocessable_content
    end
  end
end
