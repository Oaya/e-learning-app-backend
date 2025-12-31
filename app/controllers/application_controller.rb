class ApplicationController < ActionController::API
  before_action :set_current_user_tenant_plan, unless: :devise_controller?

  private

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end


  def set_current_user_tenant_plan
    return unless current_api_user

    Current.user = current_api_user
    Current.tenant = current_api_user&.tenant
    Current.plan = Current.tenant&.plan

    return if Current.tenant.present?

    render_error("Tenant required", :forbidden)
  end

  def require_admin!
    user = current_api_user
    return render_error("Unauthorized", :unauthorized) unless user

    role = user.membership&.role.to_s.downcase
    return if role == "admin"

    render_error("No permission to access", :forbidden)
  end
end
