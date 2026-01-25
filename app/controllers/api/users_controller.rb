class Api::UsersController < ApplicationController
  before_action :authenticate_api_user!
  before_action :require_admin_or_instructor!, only: [ :index ]
  before_action :require_admin!, only: [:instructors]

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
        created_at: user.created_at,
        status: User.statuses[user.status]
      }
    }
  end

  # GET /api/users/instructors
  def instructors
    users = Current.tenant.users.joins(:membership).where(memberships: { role: :instructor }).order(first_name: :desc)

    render json: users.map { |user|
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        avatar: user.avatar.attached? ? rails_blob_url(user.avatar, host: request.base_url) : nil
      }
    }

  end
end
