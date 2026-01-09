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

    resources :plans, only: [ :index ]

    resources :courses do
      resources :sections, only: [ :index, :create ] do
        collection { put :reorder }
      end
      member { get :overview }
    end

    resources :sections, only: [ :show, :update, :destroy ] do
      resources :lessons, only: [ :index, :create ] do
        collection { put :reorder }
      end
    end

    resources :lessons, only: [ :show, :update, :destroy ]

    get "auth/me", to: "auth/users#me"
  end
end
