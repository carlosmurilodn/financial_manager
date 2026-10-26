module Exercises
  class CopyDay
    def initialize(user:, source_date:, dates:)
      @user = user
      @source_date = source_date
      @dates = Array(dates).map { |date| Date.iso8601(date.to_s) }.uniq.sort
    rescue Date::Error
      raise ArgumentError, "Informe datas de destino válidas."
    end

    def call
      raise ArgumentError, "Selecione ao menos um dia de destino." if @dates.empty?
      raise ArgumentError, "O dia de origem não pode ser um destino." if @dates.include?(@source_date)

      @user.with_lock do
        sources = @user.exercise_entries.where(performed_on: @source_date)
          .includes(exercise_items: :strength_exercise_logs).order(:id).lock.to_a
        raise ArgumentError, "O dia de origem não possui exercícios." if sources.empty?

        occupied = @user.exercise_entries.where(performed_on: @dates).distinct.order(:performed_on).pluck(:performed_on)
        if occupied.any?
          raise ArgumentError, "Já existem exercícios em: #{occupied.map { |date| date.strftime('%d/%m/%Y') }.join(', ')}. Remova essas datas dos destinos."
        end

        @dates.each do |date|
          sources.each { |source| copy_entry(source, date).save! }
        end
      end
      @dates
    end

    private

    def copy_entry(source, date)
      @user.exercise_entries.build(performed_on: date).tap do |entry|
        source.exercise_items.each do |source_item|
          item = entry.exercise_items.build(
            exercise_type: source_item.exercise_type,
            duration_minutes: source_item.duration_minutes,
            intensity: source_item.intensity,
            notes: source_item.notes
          )
          source_item.strength_exercise_logs.each do |source_log|
            item.strength_exercise_logs.build(
              muscle_group_id: source_log.muscle_group_id,
              strength_exercise_catalog_id: source_log.strength_exercise_catalog_id,
              sets: source_log.sets
            )
          end
        end
      end
    end
  end
end
