Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :passwords]

  get "up" => "rails/health#show", as: :rails_health_check

  as :user do
    get 'users/edit' => 'users/registrations#edit', as: 'edit_user_registration'
    put 'users' => 'users/registrations#update', as: 'user_registration'
  end

  namespace :backstore, path: "/admin" do
    root "dashboard#index"

    resources :products
    resources :sales do
      member do
        patch :cancel
      end
    end
    resources :users do
      member do
        patch :restore
      end
    end
    resources :categories
    resources :orders
  end

  namespace :storefront, path: "/" do
    resources :products, only: %i[index show]
    resource :cart, only: %i[show]
    resources :checkout, only: %i[index create]
    get "search", to: "search#index"
  end

  root "storefront/home#index"
end
