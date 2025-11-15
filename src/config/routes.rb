Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :backstore do
    root "dashboard#index"
  end

  root "storefront/home#index"
end
