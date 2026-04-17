Rails.application.routes.draw do
  root "home#index"

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
