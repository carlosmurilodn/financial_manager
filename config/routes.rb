Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :applications, :token_info
    controllers authorizations: "mcp_integration/authorizations", tokens: "mcp_integration/tokens",
      authorized_applications: "mcp_integration/authorized_applications"
  end
  get "/.well-known/oauth-protected-resource/mcp", to: "mcp_integration/metadata#resource"
  get "/.well-known/oauth-protected-resource", to: "mcp_integration/metadata#resource"
  get "/.well-known/oauth-authorization-server", to: "mcp_integration/metadata#authorization_server"
  mount McpIntegration::Endpoint.new => "/mcp"
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  root "entry#index"
  get "desenvolvimento-pessoal", to: "personal_development#index", as: :personal_development
  post "projetos/estudio-de-escrita/backup", to: "writing_backups#create", as: :writing_backup
  resources :writing_books, path: "projetos/estudio-de-escrita" do
    member { get :cover, path: "capa" }
    member { get :read, path: "ler" }
    resource :writing_productivity, controller: "writing_productivity", path: "estatisticas/produtividade", only: :show
    resource :writing_statistics, controller: "writing_statistics", path: "estatisticas", only: :show
    resource :writing_publication, path: "publicacao", only: %i[show create] do
      get :status
      get :download, path: "arquivo"
    end
    resource :writing_narrative_context, path: "contexto-narrativo", only: %i[show create destroy]
    resources :writing_timeline_events, path: "linha-do-tempo" do
      member { patch :reorder, path: "ordenar" }
    end
    resources :writing_notes, path: "notas-e-ideias"
    resources :writing_scenes, path: "cenas", only: %i[new create show edit update destroy] do
      member do
        get :export, path: "exportar"
        patch :move, path: "mover"
        patch :reorder, path: "ordenar"
      end
    end
    resources :writing_plots, path: "tramas"
    resources :writing_conflicts, path: "conflitos"
    resources :writing_locations, path: "locais" do
      member { get :image, path: "imagem" }
    end
    resources :writing_organizations, path: "organizacoes"
    resources :writing_universe_rules, path: "regras-do-universo"
    resources :writing_characters, path: "personagens" do
      member { get :image, path: "imagem" }
      resources :writing_relationships, path: "relacionamentos", only: %i[new create edit update destroy]
    end
    resources :writing_chapters, path: "capitulos", only: %i[new create show edit update destroy] do
      member do
        get :export, path: "exportar"
        patch :reorder, path: "ordenar"
      end
    end
  end
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
  resources :exercise_entries, path: "progresso/exercicios", as: :health_exercises, only: %i[index show new create edit update destroy] do
    member do
      get :duplicate, path: "duplicar"
    end

    collection do
      delete :clear_filters
    end
  end
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
  resources :muscle_groups, path: "progresso/cadastros/grupos-musculares", only: %i[index new create edit update destroy] do
    collection do
      delete :clear_filters
    end
  end
  resources :strength_exercise_catalogs, path: "progresso/cadastros/exercicios-musculacao", only: %i[index new create edit update destroy] do
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
