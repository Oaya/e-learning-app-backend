class  Api::SubscriptionsController < ApplicationController
  before_action :authenticate_api_user!, :require_admin!, :set_current_user_tenant_plan
  before_action :require_billing_owner!, only: [ :change_plan, :cancel ]

  # GET /api/subscriptions/payment_checkout
  def payment_checkout
    plan = Plan.find_by(name: params[:plan])
    payload = Subscriptions.new.checkout_session(plan, Current.user)
    render json: payload, status: :ok
  end

  # POST /api/subscription/cancel
  def cancel
    tenant = Current.tenant

    payload = Subscriptions.new.cancel_subscription(tenant)
    render json: payload, status: :ok
  end


  # POST /api/subscription/change_plan
  def change_plan
    tenant = Current.tenant
    # find the new plan
    new_plan = Plan.find_by(name: params[:plan])
    unless new_plan
      return render_error("Invalid plan: #{params[:plan]}", :unprocessable_entity)
    end
    payload = Subscriptions.new.change_plan(tenant, new_plan)
    render json: payload, status: :ok
  end
end
