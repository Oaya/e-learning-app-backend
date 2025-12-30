module Api
  module Auth
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json

      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        if resource.errors.empty?
          render json: { message: "Email confirmed successfully" }, status: :ok
        else
          render_error(resource.errors.full_messages, :unprocessable_entity)
        end
      end
    end
  end
end
