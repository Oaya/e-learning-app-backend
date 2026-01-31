Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    devise_for :users,
      path: "auth",
      defaults: { format: :json },
      controllers: {
        registrations: "api/auth/registrations",
        sessions: "api/auth/sessions",
        confirmations: "api/auth/confirmations",
        invitations: "api/auth/invitations"
      },
      only: [ :registrations, :sessions, :confirmations, :invitations ]

    resources :users, only: [ :index, :show, :update, :destroy ] do
      collection do
        get :instructors
      end
    end

    resources :plans, only: [ :index ]

    resources :courses do
      resources :sections, only: [ :index, :create ] do
        collection { put :reorder }
      end
      member do
        get :overview
        patch :price
        patch :publish
      end
    end

    resources :sections, only: [ :show, :update, :destroy ] do
      resources :lessons, only: [ :index, :create ] do
        collection { put :reorder }
      end
    end

    resources :lessons, only: [ :show, :update, :destroy ]

    get "auth/me", to: "auth/users#me"
    patch "auth/me", to: "auth/users#update_me"
    patch "auth/me/password", to: "auth/users#update_password"

    post "rails/active_storage/direct_uploads", to: "active_storage/direct_uploads#create"
  end
end
