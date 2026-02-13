class Api::StripeWebhooksController < ApplicationController
  def receive
    payload = request.raw_post

    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
    signature = request.headers["Stripe-Signature"]

    begin
      event =
        if endpoint_secret.present?
          Stripe::Webhook.construct_event(payload, signature, endpoint_secret)
        else
          Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
        end
    rescue JSON::ParserError => e
      return render_error("Invalid payload: #{e.message}", :bad_request)
    rescue Stripe::SignatureVerificationError => e
      return render_error("Invalid signature: #{e.message}", :bad_request)
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      if session.present?
        create_signup_user(session)
      else
        Rails.logger.error("Session data missing in event: #{event.id}")
      end
    end

      head :ok
  rescue => e
    Rails.logger.error("Error processing webhook: #{e.full_message}")
    render_error("Internal server error", :internal_server_error)
  end

  private

  def create_signup_user(session)
    pp "Handling checkout.session.completed event"
    Rails.logger.info(JSON.pretty_generate(session.to_h))
    # get the customer id and subscription id from the session
    customer_id = session.customer
    subscription_id = session.subscription

    user_data = session.metadata

    # first create the tenant with the email and name from the metadata, and save the stripe customer id and subscription id in the tenant record
    tenant = Tenant.create!(
      name: user_data.tenant.to_s,
      plan_id: user_data.plan_id.to_s,
      stripe_customer_id: customer_id.to_s,
      stripe_subscription_id: subscription_id.to_s,
    )

    # then create the user and associate it with the tenant
    user = User.create!(
      email: user_data.email.to_s,
      first_name: user_data.first_name.to_s,
      last_name: user_data.last_name.to_s,
      password: Devise.friendly_token[0, 20],
      tenant: tenant
    )

    # finally create the membership to link the user and tenant with the default role
    Membership.create!(
      user: user,
      tenant: tenant,
      role: :admin
    )

    # and then send a welcome email to the user

  rescue => e
    Rails.logger.error("Error handling checkout session completed: #{e.full_message}")
  end
end
