Rails.application.routes.draw do
  root "home#index"

  get "sign_up" => "users#new", as: :sign_up
  post "users" => "users#create"
  get "login" => "sessions#new", as: :login
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy", as: :logout
  post "session/close" => "sessions#close", as: :close_session

  get "passkeys/setup" => "passkeys#setup", as: :passkeys_setup
  post "passkeys/registration/options" => "passkeys#registration_options", as: :passkey_registration_options
  post "passkeys/registration" => "passkeys#create", as: :passkey_registration
  post "passkeys/authentication/options" => "passkeys#authentication_options", as: :passkey_authentication_options
  post "passkeys/authentication" => "passkeys#authenticate", as: :passkey_authentication

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "passkey_test" => "passkey_test#index"

  resources :expenses do
    member do
      get :delete_options
      get :toggle_paid_options
      patch :toggle_paid
    end
    collection do
      delete :clear_filters
      post :analyze_invoice
      post :confirm_invoice_import
      get :import_invoice
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
  resources :financial_goals

  resources :cards do
    member do
      post :pay
    end
  end

  resources :reports, only: [:index] do
    collection do
      get :forecast
      get :forecast_pdf
    end
  end
end
