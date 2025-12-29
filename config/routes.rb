Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    devise_for :users,
      path: "auth",
      defaults: { format: :json },
      controllers: {
        registrations: "api/auth/registrations",
        sessions: "api/auth/sessions"
      },
      only: [ :registrations, :sessions, :confirmations ]

    resources :plans, only: [ :index ]
  end
end
