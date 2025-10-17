Rails.application.routes.draw do
  root "home#index"

  # 💸 DESPESAS
  resources :expenses do
    member do
      patch :toggle_paid
    end
    collection do
      delete :clear_filters
      get :report          # Página com filtros e tabela
      get :report_pdf      # Geração do PDF
    end
  end

  # 💰 RECEITAS
  resources :incomes do
    member do
      patch :toggle_paid
    end
    collection do
      delete :clear_filters
    end
  end

  # 🏷️ CATEGORIAS
  resources :categories

  # 💳 CARTÕES
  resources :cards do
    member do
      post :pay
    end
  end

  # 📅 PARCELAS
  resources :installments, only: [:edit, :update, :destroy] do
    patch :toggle_paid, on: :member
  end

  # 📊 RELATÓRIOS
  resources :reports, only: [:index] do
    collection do
      get :forecast        # Tela com filtros
      get :forecast_pdf    # Geração do PDF
    end
  end
end
