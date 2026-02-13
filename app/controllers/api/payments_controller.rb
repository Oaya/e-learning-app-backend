class  Api::PaymentsController < ApplicationController
  skip_before_action :set_current_user_tenant_plan, only: [ :checkout ]

  # POST /api/payments/checkout
  def checkout
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

    payload = payment_params

    plan = Plan.find_by(name: payload[:plan].to_s)

    unless plan
      return render_error("Invalid plan: #{payload[:plan]}", :unprocessable_entity)
    end

    unless plan.stripe_price_id.present?
      return render_error("Plan is missing Stripe price id", :unprocessable_entity)
    end

    # Create or reuse a Stripe customer by email
    customer = Stripe::Customer.list(email: payload[:email]).data.first
    customer ||= Stripe::Customer.create(
      email: payload[:email],
      name: "#{payload[:first_name]} #{payload[:last_name]}",
      metadata: { tenant: payload[:tenant].to_s }
    )

    frontend = Rails.application.credentials[:frontend_url] || "http://localhost:5173"

    # Put signup info into metadata so you can create the user after payment is successful in the webhook
    begin
      session = Stripe::Checkout::Session.create(
        ui_mode: "embedded",
        mode: "subscription",
        customer: customer.id,
        line_items: [ { price: plan.stripe_price_id, quantity: 1 } ],
        return_url: "#{frontend}/signup/payment-complete?session_id={CHECKOUT_SESSION_ID}",
        metadata: {
          "email" => payload[:email].to_s,
          "first_name" => payload[:first_name].to_s,
          "last_name" => payload[:last_name].to_s,
          "tenant" => payload[:tenant].to_s,
          "plan_name" => plan.name.to_s,
          "plan_id" => plan.id.to_s
        }
      )
    rescue Stripe::StripeError => e
      return render_error(e.message, :bad_request)
    end

    render json: { client_secret: session.client_secret }, status: :ok
  end

  private

  def payment_params
    params.permit(:email, :first_name, :last_name, :tenant, :plan)
  end
end
