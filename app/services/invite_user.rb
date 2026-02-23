class InviteUser
  def initialize(tenant:, invited_by:, params:)
    @tenant = tenant
    @invited_by = invited_by
    @params = params
  end

  def call
      admin_limit_error! if @params[:role].to_s.downcase == "admin"

      existing = User.find_by(email: @params[:email])

      if existing.present?
        # If the user already exists, don't resend the invitation email
        if existing.status == "active"
          return existing
        end
        # If the user exists but is not active, we can resend the invitation email by calling invite! again
        existing.deliver_invitation
        return existing
      end

      invited_user = User.invite!(
        {
          email: @params[:email],
          first_name: @params[:first_name],
          last_name: @params[:last_name],
          tenant_id: @tenant.id,
          status: "invited"
        },
      )

      return invited_user if invited_user.errors.any?

      invited_user.tap do |u|
        # If invite failed, let controller handle errors
        return u if u.errors.any?

        # Create membership for invited user
        Membership.find_or_create_by!(
          user: invited_user,
          tenant_id: @tenant.id,
          role: @params[:role]
        )
      end
  end

  private

  def admin_limit_error!
    max = @tenant.plan.features["max_admin"]

    user = User.find_by(email: @params[:email])

    count = @tenant.memberships.where(role: "admin").count

    return if count < max || user&.membership&.role.to_s.downcase == "admin"

    raise StandardError, "Your plan allows only #{max} admin memberships"
  end
end
