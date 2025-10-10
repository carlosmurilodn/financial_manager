Rails.application.routes.draw do
  root "home#index"

  resources :expenses do
    member do
      patch :toggle_paid
    end

    collection do
      delete :clear_filters
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

  resources :installments, only: [:edit, :update, :destroy] do
    patch :toggle_paid, on: :member
  end
end
