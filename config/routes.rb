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
      resources :course_modules, only: [ :index, :create ]
    end

    resources :course_modules, only: [ :show, :update, :destroy ]
  end
end
