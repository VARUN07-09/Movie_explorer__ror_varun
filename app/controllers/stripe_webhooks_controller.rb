class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /webhooks/stripe
  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']  # Secret for webhook verification

    event = nil

    # Verify the webhook signature
    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      return head :bad_request # Invalid payload
    rescue Stripe::SignatureVerificationError => e
      return head :unauthorized # Invalid signature
    end

    # Handle the event based on its type
    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      
      # Retrieve user and subscription plan information from metadata
      user_id = session['metadata']['user_id']
      subscription_plan_id = session['metadata']['subscription_plan_id']

      begin
        user = User.find(user_id)
        subscription_plan = SubscriptionPlan.find(subscription_plan_id)

        # Create a UserSubscription record
        user_subscription = UserSubscription.create(
          user: user,
          subscription_plan: subscription_plan,
          start_date: Date.today,
          end_date: Date.today + subscription_plan.duration_months.months,
          status: :active
        )

        # You can also handle sending a confirmation email or logging actions here

      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("User or Subscription Plan not found: #{e.message}")
      end
    end

    # Respond with OK status to acknowledge receipt of the event
    head :ok
  end
end
