class InviteUser
  def initialize(tenant:, invited_by:, params:)
    @tenant = tenant
    @invited_by = invited_by
    @params = params
  end

  def call
      # Invite user into the SAME tenant as the current user
      @email = @params[:email].to_s.downcase

      admin_limit_error! if @params[:role].to_s.downcase == "admin"

      invited_user = User.invite!(
        {
          email: @email,
          first_name: @params[:first_name],
          last_name: @params[:last_name],
          tenant_id: @tenant.id,
          status: "invited"
        },
        @invited_by
      )

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

    user = User.find_by(email: @email)

    count = @tenant.memberships.where(role: "admin").count

    return if count < max || user&.membership&.role.to_s.downcase == "admin"

    raise StandardError, "Your plan allows only #{max} admin memberships"
  end
end
