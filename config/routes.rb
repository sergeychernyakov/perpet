Rails.application.routes.draw do
  root "pages#home"

  get "about", to: "pages#about", as: :about
  get "support", to: "support#show", as: :support

  resources :ads, only: %i[index]
  resources :articles, only: %i[index]
  resources :support_tickets, only: %i[create]
  resources :leads, only: %i[create]

  resource :profile, only: %i[show update], controller: "profiles"

  # Проверка живости приложения для мониторинга и балансировщиков.
  get "up" => "rails/health#show", as: :rails_health_check
end
