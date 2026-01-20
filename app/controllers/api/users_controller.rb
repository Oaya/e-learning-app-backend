class  Api::UsersController < ApplicationController
  before_action :authenticate_api_user!
  before_action :require_admin_or_instructor!, only: [ :index ]

  # GET /api/users
  def index
    users = Current.tenant.users.includes(:membership).order(created_at: :desc)
    render json: users.map { |user|
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        role: Membership.roles[user.membership&.role],
        created_at: user.created_at
      }
    }
  end
end
