class WritingNarrativeController < ApplicationController
  before_action :set_book
  before_action :set_record, only: %i[show edit update destroy image]
  helper_method :narrative_model, :narrative_collection_path

  def index
    scope = narrative_scope
    @query = params[:query].to_s.strip
    if @query.present?
      pattern = "%#{narrative_model.sanitize_sql_like(@query)}%"
      scope = narrative_model == WritingNote ? scope.where("title ILIKE ? OR description ILIKE ?", pattern, pattern) : scope.where("#{narrative_model::NAME_FIELD} ILIKE ?", pattern)
    end
    %i[kind status intensity category].each do |field|
      scope = scope.where(field => params[field]) if narrative_model::FIELDS.key?(field) && params[field].present?
    end
    @filtered_count = scope.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    scope = scope.with_attached_reference_image if narrative_model == WritingLocation
    @records = scope.order(narrative_model::NAME_FIELD, :id).limit(@per_page).offset((@current_page - 1) * @per_page)
    render "writing_narrative/index"
  end

  def show
    render "writing_narrative/show"
  end

  def new
    @record = narrative_scope.new
    render "writing_narrative/form"
  end

  def edit
    render "writing_narrative/form"
  end

  def create
    @record = narrative_scope.new
    save_record
  end

  def update
    save_record
  end

  def destroy
    @book.with_lock { @record.destroy! }
    redirect_to narrative_collection_path, notice: "Registro excluído com sucesso!", status: :see_other
  end

  def image
    return head :not_found unless @record.is_a?(WritingLocation) && @record.reference_image.attached?

    response.headers["Cache-Control"] = "private, no-store"
    send_data @record.reference_image.download, type: @record.reference_image.content_type, disposition: "inline"
  end

  private

  def set_book
    @book = current_user.writing_books.find(params[:writing_book_id])
  end

  def narrative_scope
    @book.public_send(narrative_model.model_name.route_key)
  end

  def set_record
    @record = narrative_scope.find(params[:id])
  end

  def narrative_collection_path
    polymorphic_path([ @book, narrative_model ])
  end

  def record_params
    fields = narrative_model::FIELDS.keys
    fields << :parent_plot_id if narrative_model == WritingPlot
    fields += %i[parent_location_id reference_image] if narrative_model == WritingLocation
    fields << :writing_location_id if narrative_model == WritingOrganization
    associations = {}
    associations[:writing_character_ids] = [] if [ WritingPlot, WritingConflict ].include?(narrative_model)
    associations[:writing_plot_ids] = [] if narrative_model == WritingConflict
    associations[:writing_organization_memberships_attributes] = %i[id writing_character_id role _destroy] if narrative_model == WritingOrganization
    attributes = params.require(narrative_model.model_name.param_key).permit(*fields, **associations)
    attributes.delete(:reference_image) if attributes[:reference_image].blank?
    validate_association_ids(attributes)
    attributes
  end

  def validate_association_ids(attributes)
    { parent_plot_id: :writing_plots, parent_location_id: :writing_locations, writing_location_id: :writing_locations }.each do |field, collection|
      @book.public_send(collection).find(attributes[field]) if attributes[field].present?
    end
    { writing_character_ids: :writing_characters, writing_plot_ids: :writing_plots }.each do |field, collection|
      next unless attributes.key?(field)

      attributes[field] = attributes[field].reject(&:blank?).map(&:to_i).uniq
      @book.public_send(collection).find(attributes[field]) if attributes[field].any?
    end
    attributes.fetch(:writing_organization_memberships_attributes, {}).each_value do |membership|
      @record.writing_organization_memberships.find(membership[:id]) if membership[:id].present?
      @book.writing_characters.find(membership[:writing_character_id]) if membership[:writing_character_id].present?
    end
  end

  def save_record
    attributes = record_params
    saved = false
    @book.with_lock do
      @record.assign_attributes(attributes)
      saved = @record.save
      after_narrative_save if saved
      raise ActiveRecord::Rollback unless saved
    end
    if saved
      remove_reference_image
      redirect_to [ @book, @record ], notice: "Registro salvo com sucesso!", status: :see_other
    else
      render "writing_narrative/form", status: :unprocessable_content
    end
  rescue ActiveRecord::RecordInvalid => error
    raise unless error.record == @record

    render "writing_narrative/form", status: :unprocessable_content
  end

  def after_narrative_save
  end

  def remove_reference_image
    return unless @record.is_a?(WritingLocation)
    return unless ActiveModel::Type::Boolean.new.cast(params.dig(:writing_location, :remove_reference_image))
    return if params.dig(:writing_location, :reference_image).present?

    @record.reference_image.purge if @record.reference_image.attached?
  end
end
