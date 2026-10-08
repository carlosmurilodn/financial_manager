class PhysicalHealthController < ApplicationController
  EXERCISE_CATEGORIES = { "training" => "Musculação", "functional" => "Treino Funcional", "walking" => "Caminhada" }.freeze
  def destroy_nutrition_week
    destroy_physical_week(:nutrition)
  end

  def destroy_exercise_week
    destroy_physical_week(:exercise)
  end
  def edit_nutrition_week
    prepare_week_edit(:nutrition)
  end

  def edit_exercise_week
    prepare_week_edit(:exercise)
  end

  def update_nutrition_week
    update_physical_week(:nutrition)
  end

  def update_exercise_week
    update_physical_week(:exercise)
  end
  def new_nutrition_week
    new_physical_week(:nutrition)
  end

  def create_nutrition_week
    create_physical_week(:nutrition)
  end

  def new_exercise_week
    new_physical_week(:exercise)
  end

  def create_exercise_week
    create_physical_week(:exercise)
  end

  def nutrition
    load_physical_hero(:nutrition)
    if params[:week_start].present?
      week = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
      return redirect_to health_nutrition_week_path(week.iso8601)
    end
    dates = @registered_weeks + current_user.daily_calorie_entries.pluck(:occurred_on)
    @weeks = paginate_collection(filter_weeks(dates), per_page: pagination_per_page)
    @plans_by_week = current_user.weekly_health_plans.where(week_start: @weeks).includes(:weekly_health_goals).index_by(&:week_start)
    @calorie_counts = current_user.daily_calorie_entries.where(occurred_on: @weeks.flat_map { |date| (date..date + 6.days).to_a }).where.not(consumed_calories: nil).pluck(:occurred_on).map { |date| date.beginning_of_week(:monday) }.tally
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
  rescue ArgumentError
    redirect_to health_nutrition_path, alert: "Dia inválido.", status: :see_other
  end

  def exercise
    load_physical_hero(:exercise)
    if params[:week_start].present?
      week = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
      return redirect_to health_exercise_week_path(week.iso8601)
    end
    dates = @registered_weeks
    @weeks = paginate_collection(filter_weeks(dates), per_page: pagination_per_page)
    @plans_by_week = current_user.weekly_health_plans.where(week_start: @weeks).includes(:weekly_health_goals).index_by(&:week_start)
  rescue ArgumentError
    redirect_to health_exercise_path, alert: "Semana inválida."
  end

  def exercise_week
    load_exercise_week
  rescue ArgumentError
    redirect_to health_exercise_path, alert: "Semana inválida."
  end

  def toggle_exercise_day
    date = Date.iso8601(params[:occurred_on].to_s)
    type = params[:activity].to_s
    raise ArgumentError unless EXERCISE_CATEGORIES.key?(type)
    current_user.with_lock do
      load_exercise_week
      raise ArgumentError unless date.between?(@week_start, @week_start + 6.days)
      goal = exercise_goal(@plan, type)
      raise ArgumentError unless goal
      day = goal.weekly_health_goal_days.find_or_initialize_by(occurred_on: date)
      day.update!(completed: !day.completed?)
      goal.sync_completed_count!
      Health::RecalculateDailyCalories.new(user: current_user, dates: [date]).call
    end
    redirect_to health_exercise_week_path(@week_start.iso8601), status: :see_other
  rescue ArgumentError
    redirect_to health_exercise_path, alert: "Dia ou atividade inválida.", status: :see_other
  end

  private

  def destroy_physical_week(area)
    current_user.with_lock do
      area == :nutrition ? load_nutrition_week : load_exercise_week
      if area == :nutrition
        @nutrition_goal&.destroy!
        current_user.daily_calorie_entries.where(occurred_on: @week_start..@week_start + 6.days).destroy_all
      else
        EXERCISE_CATEGORIES.keys.filter_map { |type| exercise_goal(@plan, type) }.uniq.each(&:destroy!)
        Health::RecalculateDailyCalories.new(user: current_user, dates: (@week_start..@week_start + 6.days).to_a).call
      end
      @plan.destroy! if @plan && !@plan.weekly_health_goals.exists?
    end
    redirect_to area == :nutrition ? health_nutrition_path : health_exercise_path, notice: "Semana excluída.", status: :see_other
  rescue ArgumentError
    redirect_to area == :nutrition ? health_nutrition_path : health_exercise_path, alert: "Semana inválida.", status: :see_other
  end

  def prepare_week_edit(area)
    area == :nutrition ? load_nutrition_week : load_exercise_week
    @editing = true
    @physical_area = area
    @selected_week = @week_start.iso8601
    @selected_activities = EXERCISE_CATEGORIES.keys.select { |type| exercise_goal(@plan, type) }
    render :new_week
  rescue ArgumentError
    redirect_to area == :nutrition ? health_nutrition_path : health_exercise_path, alert: "Semana inválida."
  end

  def update_physical_week(area)
    @editing = true
    @physical_area = area
    @selected_activities = Array(params[:activities]).reject(&:blank?).uniq
    current_user.with_lock do
      area == :nutrition ? load_nutrition_week : load_exercise_week
      @selected_week = @week_start.iso8601
      if area == :exercise
        raise ArgumentError, "Selecione pelo menos uma categoria válida." if @selected_activities.empty? || (@selected_activities - EXERCISE_CATEGORIES.keys).any?
        removed = (EXERCISE_CATEGORIES.keys - @selected_activities).filter_map { |type| exercise_goal(@plan, type) }
        raise ArgumentError, "Desmarque os dias realizados antes de remover uma categoria." if removed.any? { |goal| goal.completed_count.positive? || goal.weekly_health_goal_days.any?(&:completed?) }
        targets = selected_exercise_targets
        @plan ||= current_user.weekly_health_plans.create!(week_start: @week_start)
        removed.each(&:destroy!)
        @selected_activities.each do |type|
          goal = exercise_goal(@plan, type) || @plan.weekly_health_goals.build(name: EXERCISE_CATEGORIES.fetch(type), completed_count: 0)
          goal.update!(target_count: targets.fetch(type))
        end
        Health::RecalculateDailyCalories.new(user: current_user, dates: (@week_start..@week_start + 6.days).to_a).call
      else
        @plan ||= current_user.weekly_health_plans.create!(week_start: @week_start)
        @nutrition_goal ||= @plan.weekly_health_goals.build(name: "Alimentação", completed_count: 0)
        @nutrition_goal.update!(target_count: 7, notes: params[:notes].to_s)
      end
    end
    redirect_to area == :nutrition ? health_nutrition_week_path(@week_start.iso8601) : health_exercise_week_path(@week_start.iso8601), notice: "Semana atualizada.", status: :see_other
  rescue ArgumentError, ActiveRecord::RecordInvalid => error
    @selected_week ||= params[:week_start]
    flash.now[:alert] = error.message
    render :new_week, status: :unprocessable_entity
  end

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

  def load_physical_hero(area)
    @physical_area = area
    goals = current_user.weekly_health_goals.includes(:weekly_health_plan).to_a
    if area == :nutrition
      goals = goals.select { |goal| goal.name.parameterize == "alimentacao" }
      @registered_weeks = goals.map { |goal| goal.weekly_health_plan.week_start }.uniq
      @hero_kpis = [
        ["Semanas Registradas", "calendar_month", goals.map { |goal| goal.weekly_health_plan.week_start }.uniq.size],
        ["Dias de Alimentação", "restaurant", goals.sum(&:completed_count)],
        ["Calorias Preenchidas", "local_fire_department", current_user.daily_calorie_entries.where.not(consumed_calories: nil).count]
      ]
    else
      training = goals.select { |goal| (goal.name.parameterize.split("-") & Health::DailyCalorieCalculation::TRAINING_WORDS).any? }
      walking = goals.select { |goal| (goal.name.downcase.scan(/[[:alnum:]_]+/) & Health::DailyCalorieCalculation::WALKING_WORDS).any? }
      @registered_weeks = (training + walking).map { |goal| goal.weekly_health_plan.week_start }.uniq
      @hero_kpis = [
        ["Semanas Registradas", "calendar_month", (training + walking).map { |goal| goal.weekly_health_plan.week_start }.uniq.size],
        ["Exercícios Realizados", "fitness_center", training.sum(&:completed_count)],
        ["Caminhadas Realizadas", "directions_walk", walking.sum(&:completed_count)]
      ]
    end
  end

  def new_physical_week(area)
    @physical_area = area
    @selected_week = Date.current.beginning_of_week(:monday).iso8601
    @selected_activities = []
    render :new_week
  end

  def create_physical_week(area)
    week = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
    @selected_activities = Array(params[:activities]).reject(&:blank?).uniq
    if area == :exercise && (@selected_activities.empty? || (@selected_activities - EXERCISE_CATEGORIES.keys).any?)
      @physical_area = area
      @selected_week = week.iso8601
      flash.now[:alert] = "Selecione pelo menos uma categoria de exercício válida."
      return render :new_week, status: :unprocessable_entity
    end
    targets = selected_exercise_targets if area == :exercise
    current_user.with_lock do
      plan = current_user.weekly_health_plans.find_or_create_by!(week_start: week)
      if area == :nutrition
        unless plan.weekly_health_goals.any? { |goal| goal.name.parameterize == "alimentacao" }
          plan.weekly_health_goals.create!(name: "Alimentação", target_count: 7, completed_count: 0)
        end
      else
        @selected_activities.each do |type|
          name = EXERCISE_CATEGORIES.fetch(type)
          plan.weekly_health_goals.create!(name: name, target_count: targets.fetch(type), completed_count: 0) unless exercise_goal(plan, type)
        end
      end
    end
    redirect_to area == :nutrition ? health_nutrition_week_path(week.iso8601) : health_exercise_week_path(week.iso8601), notice: "Semana pronta para acompanhar. Registros existentes preservados.", status: :see_other
  rescue ArgumentError => error
    @physical_area = area
    @selected_week = params[:week_start]
    flash.now[:alert] = error.message == "A frequência deve ser de 1 a 7 dias." ? error.message : "Selecione uma semana válida."
    render :new_week, status: :unprocessable_entity
  end

  def selected_exercise_targets
    @selected_activities.to_h do |type|
      value = params.fetch(:targets, {})[type].to_s
      raise ArgumentError, "A frequência deve ser de 1 a 7 dias." unless value.match?(/\A[1-7]\z/)
      [type, value.to_i]
    end
  end

  def exercise_goal(plan, type)
    names = case type
    when "training" then %w[musculacao treino treinar]
    when "functional" then ["treino-funcional", "funcional"]
    when "walking" then %w[caminhada caminhar]
    else []
    end
    plan&.weekly_health_goals&.find { |goal| names.include?(goal.name.parameterize) }
  end

  def exercise_categories
    EXERCISE_CATEGORIES
  end
  helper_method :exercise_goal, :exercise_categories

  def load_exercise_week
    @week_start = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
    @plan = current_user.weekly_health_plans.includes(weekly_health_goals: :weekly_health_goal_days).find_by(week_start: @week_start)
  end

  def load_nutrition_week
    @week_start = Date.iso8601(params[:week_start].to_s).beginning_of_week(:monday)
    @plan = current_user.weekly_health_plans.includes(weekly_health_goals: :weekly_health_goal_days).find_by(week_start: @week_start)
    @nutrition_goal = @plan&.weekly_health_goals&.find { |goal| goal.name.parameterize == "alimentacao" }
  end
end
