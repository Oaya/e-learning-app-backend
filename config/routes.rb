Rails.application.routes.draw do
  resources :users
  resources :memberships
  resources :tenants

  namespace :api do
    resources :plans, only: [ :index ]
  end
end
