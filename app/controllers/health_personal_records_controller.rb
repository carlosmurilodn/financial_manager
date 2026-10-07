class HealthPersonalRecordsController < ApplicationController
  include SelfKnowledgeHero
  before_action :load_self_knowledge_hero, only: :index
  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
  before_action :set_area
  before_action :set_record, only: %i[show edit update destroy]
  before_action :load_week_options, only: %i[new create edit update]

  def index
    records = collection.order(date_field => :desc)
    @date_from = valid_iso_date(params[:date_from])
    @date_to = valid_iso_date(params[:date_to])
    if weekly?
      @date_from = @date_from&.beginning_of_week
      @date_to = @date_to&.beginning_of_week
      load_week_options
    end
    records = records.where(date_field => @date_from..) if @date_from
    records = records.where(date_field => ..@date_to) if @date_to
    @records = paginate_collection(records.to_a, per_page: pagination_per_page)
    render "self_knowledge/records"
  end

  def new
    date = valid_iso_date(params[:date]) || Date.current
    date = date.beginning_of_week if weekly?
    @record = collection.find_or_initialize_by(date_field => date)
    render "self_knowledge/form"
  end

  def edit
    render "self_knowledge/form"
  end

  def create
    attributes = record_params
    date = selected_date(attributes)
    saved = current_user.with_lock do
      @record = collection.find_or_initialize_by(date_field => date)
      if @record.persisted?
        @existing_record = @record
        false
      else
        @record.assign_attributes(attributes.except(date_field))
        @record.save
      end
    end
    finish_save(saved)
  end

  def update
    attributes = record_params
    @record.assign_attributes(attributes.except(date_field))
    @record.public_send("#{date_field}=", selected_date(attributes))
    saved = current_user.with_lock { @record.save }
    finish_save(saved)
  rescue ActiveRecord::RecordNotUnique
    @record.errors.add(date_field, "já possui um registro. Abra o registro existente.")
    render "self_knowledge/form", status: :unprocessable_content
  end

  def show
    render "self_knowledge/show"
  end

  def destroy
    @record.destroy!
    redirect_to collection_path, notice: "Registro excluído com sucesso.", status: :see_other
  end

  private

  def set_record
    date = valid_iso_date(params[date_field])
    raise ActiveRecord::RecordNotFound unless date
    @record = collection.find_by!(date_field => date)
  end

  def finish_save(saved)
    if @existing_record
      redirect_to edit_record_path(@existing_record), notice: "Já existe um registro neste período. Abra as respostas existentes para editar.", status: :see_other
    elsif saved
      if weekly? && params[:continue].present?
        redirect_to edit_health_weekly_reflection_path(@record, step: params[:continue].to_i.clamp(0, 2)), notice: "Etapa salva. Você pode continuar no seu ritmo.", status: :see_other
      else
        redirect_to record_path(@record), notice: weekly? ? "Revisão semanal salva com sucesso." : "Diário salvo com sucesso.", status: :see_other
      end
    else
      render "self_knowledge/form", status: :unprocessable_content
    end
  end

  def selected_date(attributes)
    if weekly?
      valid_iso_date(params[:selected_week])
    else
      value = attributes[date_field].to_s
      Date.strptime(value, "%d/%m/%Y") if value.match?(/\A\d{2}\/\d{2}\/\d{4}\z/)
    end
  rescue ArgumentError
    nil
  end

  def valid_iso_date(value)
    Date.iso8601(value.to_s) if value.present?
  rescue ArgumentError
    nil
  end

  def load_week_options
    return unless weekly?
    reference = @record&.week_start || valid_iso_date(params[:selected_week]) || valid_iso_date(params[:date]) || Date.current
    years = [Date.current.cwyear, reference.cwyear]
    if action_name == "index"
      years.concat(collection.distinct.pluck(:week_start).map(&:cwyear))
      years.concat([@date_from, @date_to].compact.map(&:cwyear))
    end
    @week_options = years.uniq.sort.flat_map do |year|
      (1..Date.new(year, 12, 28).cweek).map do |number|
        start = Date.commercial(year, number, 1)
        ["Semana #{number} - De #{start.strftime('%d/%m/%Y')} a #{(start + 6.days).strftime('%d/%m/%Y')}", start.iso8601]
      end
    end
  end

  helper_method :weekly?, :collection_path, :record_path, :edit_record_path, :record_title

  def weekly?
    @area == "weekly"
  end

  def collection_path
    weekly? ? health_weekly_reflections_path : health_journal_entries_path
  end

  def record_path(record)
    weekly? ? health_weekly_reflection_path(record) : health_journal_entry_path(record)
  end

  def edit_record_path(record)
    weekly? ? edit_health_weekly_reflection_path(record) : edit_health_journal_entry_path(record)
  end

  def record_title(record)
    date = record.reference_date
    return "Escolha o período do registro" unless date
    weekly? ? "Semana de #{date.strftime('%d/%m/%Y')} a #{(date + 6.days).strftime('%d/%m/%Y')}" : I18n.l(date, format: :long)
  end
end
