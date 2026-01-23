module Api
  module Auth
    class UsersController < ApplicationController
      before_action :authenticate_api_user!
      include Rails.application.routes.url_helpers


      def me
        user = Current.user
        return render_error("Not authenticated", status: :unauthorized) unless user

        render json: serialize_user(user)
      end


      def update_me
        user = Current.user
        return render_error("Not authenticated", status: :unauthorized) unless user

        if user_params[:avatar].present?
          user.avatar.attach(user_params[:avatar])
        end

        user.assign_attributes(user_params.except(:avatar))
        
        user.save!


        render json: serialize_user(user)
      rescue => e

        Rails.logger.error(e.full_message)
        render_error("#{e.class}: #{e.message}", status: :internal_server_error)
      end

      private

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
          avatar: user.avatar.attached? ? rails_blob_url(user.avatar, host: request.base_url) : nil
        }
      end

      def user_params
        params.permit(:first_name, :last_name, :avatar, :email)
      end


    end
  end
end
