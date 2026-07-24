Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  root "home#index"

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
