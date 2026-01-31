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

        if user_params.key?(:avatar_signed_id)
          signed_id = user_params[:avatar_signed_id].to_s

          if signed_id.present?
            # Delete the previous attachment first
            user.avatar.purge_later if user.avatar.attached?

            user.avatar.attach(signed_id)

            # Ensure the attachment is persisted before responding
            user.reload
          else
            user.avatar.purge_later if user.avatar.attached?
          end
        end

        user.assign_attributes(user_params.except(:avatar_signed_id))
        user.save!

        render json: serialize_user(user)
      rescue => e
        Rails.logger.error(e.full_message)
        render_error("#{e.class}: #{e.message}", status: :internal_server_error)
      end

      def update_password
        user = Current.user
        return render_error("Not authenticated", status: :unauthorized) unless user
        current_password = params[:current_password]
        new_password = params[:new_password]

        unless user.valid_password?(current_password)
          return render_error("Current password is incorrect", status: :unprocessable_entity)
        end

        user.password = new_password
        if user.save
          render json: { message: "Password updated successfully" }
        else
          render_error(user.errors.full_messages, status: :unprocessable_entity)
        end
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
        params.permit(:first_name, :last_name, :avatar_signed_id, :email)
      end
    end
  end
end
