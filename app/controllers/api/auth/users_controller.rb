module Api
  module Auth
    class UsersController < ApplicationController
      def me
        user = Current.user
        return render_error("Not authenticated", :unauthorized) unless user

        render json: {
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
  end
end
