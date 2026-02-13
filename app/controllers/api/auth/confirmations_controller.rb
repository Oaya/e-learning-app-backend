module Api
  module Auth
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json

      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        frontend_url = Rails.application.credentials.frontend_url || "http://localhost:3000"

        if resource.errors.empty?
          resource.update!(status: "Active")

          # need to get the tenant plan here to decide where to redirect after confirmation, because the user can only access the frontend after confirming email, and the frontend will check the tenant plan to decide which page to show
          # if the tenant plan is free, then redirect to the dashboard, otherwise redirect to the payment page to complete the payment
          tenant = resource.tenant
          plan = tenant.plan
          if plan.name == "basic"
            redirect_to "#{frontend_url}/confirm-email?status=success&next=dashboard"
          else
            redirect_to "#{frontend_url}/confirm-email?status=success&next=payment"
          end
        else
          redirect_to "#{frontend_url}/confirm-email?status=error"
        end
      end
    end
  end
end
