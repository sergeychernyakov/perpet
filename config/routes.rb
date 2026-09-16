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

  # Проверка живости приложения для мониторинга и балансировщиков.
  get "up" => "rails/health#show", as: :rails_health_check
end
