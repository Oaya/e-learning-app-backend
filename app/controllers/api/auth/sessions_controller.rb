module Api
  module Auth
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        email = params[:email].to_s.downcase
        password = params[:password].to_s

        unless email.present? && password.present?
          return render json: { error: "Email and password are required" }, status: :unprocessable_entity
        end

        user = User.find_for_database_authentication(email: email)

        unless user&.valid_password?(password)
          return render json: { error: "Invalid email or password" }, status: :unauthorized
        end

        unless user.confirmed?
          return render json: { error: "Confirm your email before logging in" }, status: :unauthorized
        end

        payload = SignInWithJwt.new(self).issue_jwt(user, scope: :user, message: "Successfully logged in")
        render json: payload, status: :ok
      end
    end
  end
end
