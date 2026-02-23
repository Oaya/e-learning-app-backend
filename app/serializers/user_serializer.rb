class UserSerializer
  include Rails.application.routes.url_helpers

  def initialize(user, host:)
    @user = user
    @host = host
  end

  def as_json
    membership = @user.membership
    tenant = @user.tenant

    is_billing_owner = tenant&.billing_owner_id == @user.id

    {
      id: @user.id,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      role: membership&.role,
      tenant: {
        id: tenant&.id,
        name: tenant&.name,
        status: tenant&.status,
        plan: tenant&.plan&.name,
        is_billing_owner: is_billing_owner,
        current_period_end: tenant&.current_period_end,
        cancel_at_period_end: tenant&.cancel_at_period_end,
        has_stripe_subscription: tenant&.stripe_subscription_id.present? || tenant&.stripe_customer_id.present?
      },
      avatar: avatar_url
    }
  end

  private

  def avatar_url
    return nil unless @user.avatar.attached?
    rails_blob_url(@user.avatar, host: @host)
  end
end
