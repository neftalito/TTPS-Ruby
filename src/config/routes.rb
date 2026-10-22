Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations passwords]

  get "up" => "rails/health#show", as: :rails_health_check
  patch "locale", to: "locales#update", as: :locale

  as :user do
    get "users/edit" => "users/registrations#edit", as: "edit_user_registration"
    match "users", to: "users/registrations#update", via: %i[put patch], as: "user_registration"
  end

  namespace :backstore, path: "/admin" do
    root "dashboard#index"
    get "reports", to: "reports#index", as: "reports"
    resources :products, only: %i[index show new create edit update destroy] do
      member do
        patch :change_stock
        patch :restore
        delete :delete_image_attachment
        delete :delete_audio_attachment
      end
    end

    resources :sales, only: %i[index show new create destroy] do
      member do
        patch :cancel
      end
    end
    resources :users, only: %i[index new create edit update destroy] do
      member do
        patch :restore
      end
    end
  end

  namespace :storefront, path: "/" do
    resources :products, only: %i[index show]
    get "search", to: "search#index"
  end

  root "storefront/home#index"
end
