class SignInWithJwt
  # Store controller instance so we can access helpers like `resource_name`
  def initialize(controller)
    @controller = controller
  end

  # Issues a JWT for a user and returns a payload for the frontend
  def issue_jwt(user, scope: nil, message: nil)
    # Determine Devise scope (:user by default)
    # resource_name exists on Devise controllers, fallback keeps it safe
    scope ||= @controller.send(:resource_name) rescue :user

    # Generate a JWT for this user WITHOUT using sessions
    # This returns an array: [token, payload] just get the token
    jwt, = Warden::JWTAuth::UserEncoder.new.call(user, scope, nil)


    # Safety check: if token generation failed, raise immediately
    raise "Could not generate authentication token" if jwt.blank?

    {
      message: message,
      token: jwt,
      user: serialize_user(user)
    }
  end

  private

  def serialize_user(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.membership&.role,
      tenant_id: user.tenant&.id,
      tenant_name: user.tenant&.name,
      plan: user.tenant&.plan&.name
    }
  end
end
