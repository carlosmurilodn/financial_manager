class PhysicalHealthController < ApplicationController
  def destroy_nutrition_week
    current_user.with_lock do
      load_nutrition_week
      @nutrition_goal&.destroy!
      current_user.daily_calorie_entries.where(occurred_on: @week_start..(@week_start + 6.days)).destroy_all
      @plan.destroy! if @plan && !@plan.weekly_health_goals.exists?
    end
    redirect_to health_nutrition_path, notice: "Semana excluída.", status: :see_other
  rescue ArgumentError
    redirect_to health_nutrition_path, alert: "Semana inválida.", status: :see_other
  end

  def edit_nutrition_week
    load_nutrition_week
    @editing = true
    @selected_week = @week_start.iso8601
    render :new_week
  rescue ArgumentError
    redirect_to health_nutrition_path, alert: "Semana inválida."
  end

  def update_nutrition_week
    @editing = true
    current_user.with_lock do
      load_nutrition_week
      @selected_week = @week_start.iso8601
      @plan ||= current_user.weekly_health_plans.create!(week_start: @week_start)
      @nutrition_goal ||= @plan.weekly_health_goals.build(name: "Alimentação", completed_count: 0)
      @nutrition_goal.update!(target_count: 7, notes: params[:notes].to_s)
    end
    redirect_to health_nutrition_week_path(@week_start.iso8601), notice: "Semana atualizada.", status: :see_other
  rescue ArgumentError, ActiveRecord::RecordInvalid => error
    @selected_week ||= params[:week_start]
    flash.now[:alert] = error.is_a?(ActiveRecord::RecordInvalid) ? error.record.errors.full_messages.to_sentence : "Selecione uma semana válida."
    render :new_week, status: :unprocessable_entity
  end

  def new_nutrition_week
    @selected_week = Date.current.beginning_of_week(:monday).iso8601
    render :new_week
  end

  def create_nutrition_week
    week = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
    current_user.with_lock do
      plan = current_user.weekly_health_plans.find_or_create_by!(week_start: week)
      unless plan.weekly_health_goals.any? { |goal| goal.name.parameterize == "alimentacao" }
        plan.weekly_health_goals.create!(name: "Alimentação", target_count: 7, completed_count: 0)
      end
    end
    redirect_to health_nutrition_week_path(week.iso8601), notice: "Semana pronta para acompanhar. Registros existentes preservados.", status: :see_other
  rescue ArgumentError
    @selected_week = params[:week_start]
    flash.now[:alert] = "Selecione uma semana válida."
    render :new_week, status: :unprocessable_entity
  end

  def nutrition
    load_nutrition_hero
    if params[:week_start].present?
      week = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
      return redirect_to health_nutrition_week_path(week.iso8601)
    end
    dates = @registered_weeks + current_user.daily_calorie_entries.pluck(:occurred_on)
    @weeks = paginate_collection(filter_weeks(dates), per_page: pagination_per_page)
    @plans_by_week = current_user.weekly_health_plans.where(week_start: @weeks).includes(:weekly_health_goals).index_by(&:week_start)
    @calorie_summaries = Health::WeeklyCalorieSummaryQuery.new(user: current_user, weeks: @weeks).call
    @calorie_counts = @calorie_summaries.transform_values { |summary| summary[:consumed][:count] }
  rescue ArgumentError
    redirect_to health_nutrition_path, alert: "Semana inválida."
  end

  def nutrition_week
    load_nutrition_week
    @daily_calorie_entries_by_date = current_user.daily_calorie_entries.where(occurred_on: @week_start..@week_start + 6.days).index_by(&:occurred_on)
    @health_profile = current_user.health_profile
  rescue ArgumentError
    redirect_to health_nutrition_path, alert: "Semana inválida."
  end

  def toggle_nutrition_day
    date = Date.iso8601(params[:occurred_on].to_s)
    status = params[:diet_status].presence
    raise ArgumentError unless status.nil? || %w[full partial none].include?(status)
    current_user.with_lock do
      load_nutrition_week
      raise ArgumentError unless date.between?(@week_start, @week_start + 6.days)
      @plan ||= current_user.weekly_health_plans.create!(week_start: @week_start)
      @nutrition_goal ||= @plan.weekly_health_goals.create!(name: "Alimentação", target_count: 7, completed_count: 0)
      day = @nutrition_goal.weekly_health_goal_days.find_or_initialize_by(occurred_on: date)
      day.update!(diet_status: status, completed: status == "full")
      @nutrition_goal.sync_completed_count!
    end
    redirect_to health_nutrition_week_path(@week_start.iso8601), status: :see_other
  rescue ActiveRecord::RecordInvalid => error
    redirect_to health_nutrition_week_path(@week_start.iso8601),
      alert: "Não foi possível salvar o status da dieta: #{error.record.errors.full_messages.to_sentence}",
      status: :see_other
  rescue ArgumentError
    redirect_to health_nutrition_path, alert: "Dia inválido.", status: :see_other
  end

  private

  def filter_weeks(dates)
    weeks = dates.map { |date| date.beginning_of_week(:monday) }.uniq.sort.reverse
    @date_from = Date.iso8601(params[:date_from]).beginning_of_week(:monday) if params[:date_from].present?
    @date_to = Date.iso8601(params[:date_to]).beginning_of_week(:monday) if params[:date_to].present?
    years = (weeks + [Date.current, @date_from, @date_to].compact).map(&:cwyear).uniq.sort
    @week_options = years.flat_map do |year|
      (1..Date.new(year, 12, 28).cweek).map do |number|
        start = Date.commercial(year, number, 1)
        ["Semana #{number} - De #{start.strftime('%d/%m/%Y')} a #{(start + 6.days).strftime('%d/%m/%Y')}", start.iso8601]
      end
    end
    weeks.select { |week| (!@date_from || week >= @date_from) && (!@date_to || week <= @date_to) }
  end

  def load_nutrition_hero
    goals = current_user.weekly_health_goals.includes(:weekly_health_plan).select { |goal| goal.name.parameterize == "alimentacao" }
    @registered_weeks = goals.map { |goal| goal.weekly_health_plan.week_start }.uniq
    @hero_kpis = [
      ["Semanas Registradas", "calendar_month", @registered_weeks.size],
      ["Dias de Alimentação", "restaurant", goals.sum(&:completed_count)],
      ["Calorias Preenchidas", "local_fire_department", current_user.daily_calorie_entries.where.not(consumed_calories: nil).count]
    ]
  end

  def load_nutrition_week
    @week_start = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
    @plan = current_user.weekly_health_plans.includes(weekly_health_goals: :weekly_health_goal_days).find_by(week_start: @week_start)
    @nutrition_goal = @plan&.weekly_health_goals&.find { |goal| goal.name.parameterize == "alimentacao" }
  end
end
