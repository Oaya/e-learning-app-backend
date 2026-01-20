module Api
  module Auth
    class InvitationsController < Devise::InvitationsController
      respond_to :json

      before_action :authenticate_api_user!, :require_admin!, :set_current_user_tenant_plan, only: [ :create ]


      # POST /api/auth/invitation Send invitation email
      def create
        invited_user = InviteUser.new(
          tenant: Current.tenant,
          invited_by: current_api_user,
          params: invite_params
        ).call

        if invited_user.errors.any?
          render_error(invited_user.errors.full_messages, status: :unprocessable_entity)
        else
          render json: { message: "Invitation Email was sent to #{invited_user.email}" }, status: :ok
        end
      rescue StandardError => e
        render_error(e.message, status: :forbidden)
      end


      # PATCH /api/auth/invitation -> Accept invitation and create password
      def update
        self.resource = accept_resource
        Rails.logger.warn("resource_name=#{resource_name}")
        Rails.logger.warn("ACCEPT_PARAMS=#{params.to_unsafe_h.inspect}")
        Rails.logger.warn("RESOURCE_ERRORS=#{resource.errors.full_messages.inspect}")

        if resource.errors.empty?
          resource.update!(status: "Active")
          payload = SignInWithJwt.new(self).issue_jwt(resource, message: "Created your new password")
          render json: payload, status: :ok
        else
          render_error(resource.errors.full_messages, status: :unprocessable_entity)
        end
      rescue => e
        render_error(e.message, status: :internal_server_error)
      end


      private

      def invite_params
        params.permit(:email, :first_name, :last_name, :role)
      end

      def accept_resource_params
        params.permit(:invitation_token, :password, :password_confirmation)
      end

    end
  end
end
