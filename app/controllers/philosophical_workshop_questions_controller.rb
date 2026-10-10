class PhilosophicalWorkshopQuestionsController < ApplicationController
  before_action :set_question, only: %i[show edit update destroy]

  def index
    scope = current_user.philosophical_workshop_questions
    @query = params[:query].to_s.strip
    if @query.present?
      pattern = "%#{PhilosophicalWorkshopQuestion.sanitize_sql_like(@query)}%"
      scope = scope.where("question ILIKE ? OR context ILIKE ? OR personal_reflection ILIKE ?", pattern, pattern, pattern)
    end
    scope = scope.where(status: params[:status]) if params[:status].present?
    @sort = %w[question status created_at updated_at].include?(params[:sort]) ? params[:sort] : "updated_at"
    @direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    @filtered_count = scope.count
    @per_page = pagination_per_page
    @total_pages = [ (@filtered_count.to_f / @per_page).ceil, 1 ].max
    @current_page = params[:page].to_i.clamp(1, @total_pages)
    @questions = scope.order(@sort => @direction, id: :asc).limit(@per_page).offset((@current_page - 1) * @per_page)
  end

  def show
  end

  def new
    @question = current_user.philosophical_workshop_questions.new
  end

  def edit
  end

  def create
    @question = current_user.philosophical_workshop_questions.new(question_params)
    if @question.save
      redirect_to @question, notice: "Questão criada com sucesso!", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      redirect_to @question, notice: "Questão atualizada com sucesso!", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy!
    redirect_to philosophical_workshop_questions_path, notice: "Questão excluída com sucesso!", status: :see_other
  end

  private

  def set_question
    @question = current_user.philosophical_workshop_questions.find(params[:id])
  end

  def question_params
    params.require(:philosophical_workshop_question).permit(:question, :context, :personal_reflection, :status)
  end
end
