Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations passwords]

  get "up" => "rails/health#show", as: :rails_health_check

  as :user do
    get "users/edit" => "users/registrations#edit", as: "edit_user_registration"
    put "users" => "users/registrations#update", as: "user_registration"
  end

  namespace :backstore, path: "/admin" do
    root "dashboard#index"
    get "reports", to: "reports#index", as: "reports"
    resources :products do
      member do
        patch :change_stock
        patch :restore
        delete :delete_image_attachment
        delete :delete_audio_attachment
      end
    end

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
  end

  namespace :storefront, path: "/" do
    resources :products, only: %i[index show]
    get "search", to: "search#index"
  end

  root "storefront/home#index"
end
