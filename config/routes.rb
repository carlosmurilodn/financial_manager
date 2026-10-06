Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  root "entry#index"
  get "financeiro", to: "home#index", as: :financial_dashboard
  get "progresso", to: "progress#index", as: :progress
  resources :weight_entries, path: "progresso/pesagens", only: %i[index new create edit update destroy]
  resources :weekly_health_plans, path: "progresso/semanas", param: :week_start, only: %i[edit update]
  resources :weekly_health_reviews, path: "progresso/revisoes", param: :week_start, only: %i[edit update]
  resources :health_wins, path: "progresso/vitorias", only: %i[new create edit update destroy]
  resource :health_weight_goal, path: "progresso/objetivo", only: %i[edit update]
  resources :weekly_wellbeings, path: "progresso/bem-estar", param: :week_start, only: %i[edit update]

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
