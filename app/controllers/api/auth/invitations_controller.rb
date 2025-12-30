module Api
  module Auth
    class InvitationsController < Devise::InvitationsController
      respond_to :json

      before_action :authenticate_api_user!
      before_action :ensure_admin!


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
          render_error(invited_user.errors.full_messages, :unprocessable_entity)
        end

        # Create membership for invited user
        Membership.find_or_create_by!(
          user: invited_user,
          tenant_id: current_api_user.tenant_id,
          role: invite_params[:role]
        )
        render json: { message: "Invitation Email was sent to #{email}" }, status: :ok
      end


      private

      def ensure_admin!
        role = current_api_user.membership&.role
        return if role.to_s.downcase == "admin"
        render_error("forbidden", :forbidden)
      end

      def invite_params
        params.permit(:email, :first_name, :last_name, :role)
      end
    end
  end
end
