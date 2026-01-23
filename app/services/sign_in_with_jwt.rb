class SignInWithJwt
  include Rails.application.routes.url_helpers
  # Store controller instance so we can access helpers like `resource_name`
  def initialize(controller)
    @controller = controller
  end

  # Issues a JWT for a user and returns a payload for the frontend
  def issue_jwt(user,  message: nil)
    # Generate a JWT for this user WITHOUT using sessions
    # This returns an array: [token, payload] just get the token
    jwt, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :api_user, nil)



    # Safety check: if token generation failed, raise immediately
    raise "Could not generate authentication token" if jwt.blank?

    {
      message: message,
      token: jwt,
      user: serialize_user(user)
    }
  end

  private

  # Always use the Devise mapping scope your app uses (:api_user)
  def detect_scope
    if @controller.respond_to?(:resource_name, true)
      @controller.send(:resource_name) # should be :api_user in your app
    else
      :api_user
    end
  end


  def serialize_user(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: Membership.roles[user.membership&.role],
      tenant_id: user.tenant&.id,
      tenant_name: user.tenant&.name,
      plan: user.tenant&.plan&.name,
      avatar: user.avatar.attached? ? rails_blob_url(user.avatar, host: @controller.request.base_url) : nil
    }
  end
end
