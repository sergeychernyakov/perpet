Rails.application.routes.draw do
  devise_for :users
  root "pages#home"

  get "about", to: "pages#about", as: :about
  get "support", to: "support#show", as: :support

  resources :ads, only: %i[index create]
  resources :articles, only: %i[index]
  resources :support_tickets, only: %i[create]
  resources :leads, only: %i[create]

  resource :profile, only: %i[show update], controller: "profiles"

  namespace :admin do
    root "dashboard#index"

    resources :ads
    resources :articles
    resources :faq_items
    resources :support_channels
    resources :support_tickets, only: %i[index destroy]
    resources :leads, only: %i[index destroy]
  end

  # API для мини-приложения VK.
  namespace :api do
    namespace :v1 do
      resources :ads, only: %i[index show create update destroy] do
        collection { get :mine }
      end
      resources :articles, only: %i[index show]
      resources :leads, only: %i[create]
      resources :support_tickets, only: %i[create]
      resource :profile, only: %i[show update], controller: "profiles"
      resource :support, only: %i[show], controller: "support"
    end
  end

  # Проверка живости приложения для мониторинга и балансировщиков.
  get "up" => "rails/health#show", as: :rails_health_check
end
