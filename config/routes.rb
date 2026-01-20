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

    resources :users, only: [ :index, :show, :update, :destroy ]

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

    # aws s3 direct upload presign
    post "aws/presigned_url", to: "aws#presigned_url"
    delete "/aws/delete_object", to: "aws#delete_object"
  end
end
