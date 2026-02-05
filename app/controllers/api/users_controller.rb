class Api::UsersController < ApplicationController
  before_action :authenticate_api_user!
  before_action :require_admin_or_instructor!, only: [ :index ]
  before_action :require_admin!, only: [ :instructors, :bulk_delete ]

  # GET /api/users
  def index
    users = Current.tenant.users.includes(:membership).order(created_at: :desc)
    render json: users.map { |user|
      user_result(user)
    }
  end

  # GET /api/users/:id
  def show
    user = Current.tenant.users.find(params[:id])
      render json: user_result(user)
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

  # DELETE /api/users/bulk_delete
  def bulk_delete
    pp params
    debugger
    user_ids = user_delete_params[:user_ids] || []
    unless user_ids.is_a?(Array)
      return render_error("user_ids must be an array", status: :bad_request)
    end

    # Only delete users within the current tenant
    users = Current.tenant.users.where(id: user_ids)

    # Prevent self-deletion
    users = users.where.not(id: current_api_user.id)

    # Delete memberships and users
    # (dependent: :destroy could handle this, but being explicit here)
    Membership.where(user_id: users.pluck(:id)).delete_all
    deleted_count = users.delete_all

    render json: { deleted_count: deleted_count }, status: :ok
  end

  # GET /api/users/:id/courses
  def courses
    user = Current.tenant.users.find(params[:id])
    courses = user.courses.order(created_at: :desc)
    render json: courses.map { |course|
      {
        id: course.id,
        title: course.title
        # include enrollment status for the course for this user
      }
    }
  end


  private

  def user_delete_params
    params.permit(user_ids: [])
  end

  def user_result(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: Membership.roles[user.membership&.role],
      created_at: user.created_at,
      status: User.statuses[user.status],
      avatar: user.avatar.attached? ? rails_blob_url(user.avatar, host: request.base_url) : nil
    }
  end
end
