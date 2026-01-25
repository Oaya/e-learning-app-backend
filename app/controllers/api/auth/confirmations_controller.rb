module Api
  module Auth
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json

      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        frontend_url = Rails.application.credentials.frontend_url || "http://localhost:3000"

        if resource.errors.empty?
          resource.update!(status: "Active")
          redirect_to "#{frontend_url}/confirm-email?status=success"
        else
          redirect_to "#{frontend_url}/confirm-email?status=error"
        end
      end
    end
  end
end
