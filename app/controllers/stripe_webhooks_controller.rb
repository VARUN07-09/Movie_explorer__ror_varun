class StripeWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def create
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil
  
      begin
        endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        render json: { error: e.message }, status: 400 and return
      end
  
      case event['type']
      when 'checkout.session.completed'
        session = event['data']['object']
        handle_successful_checkout(session)
      end
  
      render json: { message: 'success' }
    end
  
    private
  
    def handle_successful_checkout(session)
      customer_email = session['customer_details']['email']
      plan_name = session['display_items'].first['custom']['name']
      user = User.find_by(email: customer_email)
      plan = SubscriptionPlan.find_by(name: plan_name)
  
      return unless user && plan
  
      UserSubscription.create!(
        user: user,
        subscription_plan: plan,
        start_date: Time.current,
        end_date: Time.current + plan.duration.days,
        status: :active
      )
    end
  end
  