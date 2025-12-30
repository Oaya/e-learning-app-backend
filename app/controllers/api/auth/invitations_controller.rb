module Api
  module Auth
    class InvitationsController < Devise::InvitationsController
      respond_to :json

      before_action :authenticate_api_user!, :require_admin!, only: [ :create ]



      # POST /api/auth/invitation Send invitation email
      def create
        email = invite_params[:email].to_s.downcase


        # Invite user into the SAME tenant as the current user
        invited_user = User.invite!({
          email: email,
          first_name: invite_params[:first_name],
          last_name: invite_params[:last_name],
          tenant_id: current_api_user.tenant_id
        },
        current_api_user # invited_by
        )

        if invited_user.errors.any?
          return render_error(invited_user.errors.full_messages, :unprocessable_entity)
        end

        # Create membership for invited user
        Membership.find_or_create_by!(
          user: invited_user,
          tenant_id: current_api_user.tenant_id,
          role: invite_params[:role]
        )

        render json: { message: "Invitation Email was sent to #{email}" }, status: :ok
      end

      # PATCH /api/auth/invitation -> Accept invitaion and create password
      def update
        self.resource = accept_resource

        if resource.errors.empty?
          payload = SignInWithJwt.new(self).issue_jwt(resource, message: "Created your new password")
          render json: payload, status: :ok
        else
          render_error(resource.errors.full_messages, :unprocessable_entity)
        end
      rescue => e
        render_error(e.message, :internal_server_error)
      end


      private

      def invite_params
        params.permit(:email, :first_name, :last_name, :role)
      end

      def update_resource_params
        params.permit(:invitation_token, :password, :password_confirmation)
      end
    end
  end
end
