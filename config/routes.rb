Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  root "entry#index"
  get "financeiro", to: "home#index", as: :financial_dashboard
  get "progresso", to: "progress#index", as: :progress
  resource :health_profile, path: "progresso/perfil", only: %i[show create update]
  get "progresso/alimentacao", to: "physical_health#nutrition", as: :health_nutrition
  get "progresso/alimentacao/nova", to: "physical_health#new_nutrition_week", as: :new_health_nutrition_week
  post "progresso/alimentacao", to: "physical_health#create_nutrition_week"
  get "progresso/alimentacao/:week_start/editar", to: "physical_health#edit_nutrition_week", as: :edit_health_nutrition_week
  patch "progresso/alimentacao/:week_start", to: "physical_health#update_nutrition_week"
  delete "progresso/alimentacao/:week_start", to: "physical_health#destroy_nutrition_week"
  get "progresso/alimentacao/:week_start", to: "physical_health#nutrition_week", as: :health_nutrition_week
  patch "progresso/alimentacao/:week_start/dia", to: "physical_health#toggle_nutrition_day", as: :toggle_health_nutrition_day
  get "progresso/exercicios", to: "physical_health#exercise", as: :health_exercise
  get "progresso/exercicios/nova", to: "physical_health#new_exercise_week", as: :new_health_exercise_week
  post "progresso/exercicios", to: "physical_health#create_exercise_week"
  get "progresso/exercicios/:week_start/editar", to: "physical_health#edit_exercise_week", as: :edit_health_exercise_week
  patch "progresso/exercicios/:week_start", to: "physical_health#update_exercise_week"
  delete "progresso/exercicios/:week_start", to: "physical_health#destroy_exercise_week"
  get "progresso/exercicios/:week_start", to: "physical_health#exercise_week", as: :health_exercise_week
  patch "progresso/exercicios/:week_start/dia", to: "physical_health#toggle_exercise_day", as: :toggle_health_exercise_day
  resources :daily_calorie_entries, path: "progresso/calorias", param: :occurred_on, only: %i[show create]
  resources :weight_entries, path: "progresso/pesagens", only: %i[index new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end
  resources :weekly_health_plans, path: "progresso/semanas", param: :week_start, only: %i[index show new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end
  resources :weekly_health_goals, only: [] do
    member do
      patch :toggle_day
    end
  end
  get "progresso/autoconhecimento", to: "self_knowledge#index", as: :self_knowledge
  get "progresso/autoconhecimento/resumo-semanal", to: "self_knowledge#week_summary", as: :self_knowledge_week_summary
  get "progresso/autoconhecimento/evolucao", to: "self_knowledge#evolution", as: :self_knowledge_evolution
  resources :health_journal_entries, path: "progresso/autoconhecimento/diario", param: :entry_date do
    collection { get :prompt, path: "pergunta" }
  end
  resources :health_weekly_reflections, path: "progresso/autoconhecimento/semanas", param: :week_start
  resources :weekly_health_reviews, path: "progresso/perguntas", param: :week_start, only: %i[index show new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end
  resources :health_wins, path: "progresso/vitorias", only: %i[index new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end
  resources :health_weight_goals, path: "progresso/objetivos", only: %i[index new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end
  resources :weekly_wellbeings, path: "progresso/bem-estar", param: :week_start, only: %i[index new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :expenses do
    member do
      get :delete_options
      get :toggle_paid_options
      patch :toggle_paid
    end
    collection do
      delete :clear_filters
      get :report
      get :report_pdf
    end
  end

  resources :incomes do
    member do
      patch :toggle_paid
    end
    collection do
      delete :clear_filters
    end
  end

  resources :categories
  resources :financial_goals do
    collection do
      delete :clear_filters
    end
  end

  resources :cards do
    member do
      post :pay
    end

    collection do
      delete :clear_filters
    end
  end

  resources :reports, only: [ :index ] do
    collection do
      post :backup
      get :forecast
      get :forecast_pdf
    end
  end
end
