class  Api::PaymentsController < ApplicationController
  before_action :authenticate_api_user!, :require_admin!, :set_current_user_tenant_plan

  # GET /api/payments/checkout
  def checkout
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

    plan = Current.tenant.plan
    user = Current.user

    unless plan
      return render_error("Invalid plan: #{payload[:plan]}", :unprocessable_entity)
    end

    unless plan.stripe_price_id.present?
      return render_error("Plan is missing Stripe price id", :unprocessable_entity)
    end

    # Create or reuse a Stripe customer by email
    customer = Stripe::Customer.list(email: user.email).data.first
    customer ||= Stripe::Customer.create(
      email: user.email,
      name: "#{user.first_name} #{user.last_name}",
      metadata: { tenant_id: user.tenant.id }
    )

    frontend = Rails.application.credentials[:frontend_url] || "http://localhost:5173"

    # Put signup info into metadata so you can create the user after payment is successful in the webhook
    begin
      session = Stripe::Checkout::Session.create(
        ui_mode: "embedded",
        mode: "subscription",
        customer: customer.id,
        line_items: [ { price: plan.stripe_price_id, quantity: 1 } ],
        return_url: "#{frontend}/admin/dashboard",
        metadata: {
          "email" => user.email,
          "first_name" => user.first_name,
          "last_name" => user.last_name,
          "tenant_id" => user.tenant.id,
          "plan_name" => plan.name,
          "plan_id" => plan.id
        }
      )
    rescue Stripe::StripeError => e
      return render_error(e.message, :bad_request)
    end

    render json: { client_secret: session.client_secret }, status: :ok
  end

  def checkout_status
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

    session_id = params[:session_id]
    return render_error("Missing session_id", status: :bad_request) if session_id.blank?

    session = Stripe::Checkout::Session.retrieve(session_id)

    tenant = Current.tenant

    if tenant.active?
      render json: { signed_up: true }, status: :ok
    elsif session.payment_status == "paid"
      # webhook may still be processing
      render json: { signed_up: false, processing: true }, status: :ok
    else
      render json: { signed_up: false }, status: :ok
    end
  rescue Stripe::StripeError => e
    render_error(e.message, status: :bad_request)
  end
end
