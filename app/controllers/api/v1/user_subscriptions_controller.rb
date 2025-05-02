class Api::V1::UserSubscriptionsController < ApplicationController
    before_action :authorize_request # Replace with custom JWT authorization
    skip_before_action :verify_authenticity_token
  
    # POST /api/v1/user_subscriptions/buy
    # Step 1: Initiates Stripe PaymentIntent
    def buy
      subscription_plan = SubscriptionPlan.find(params[:plan_id])
      user = @current_user # We use @current_user instead of current_user
    
      # Create a PaymentIntent with Stripe
      payment_intent = Stripe::PaymentIntent.create(
        amount: (subscription_plan.price * 100).to_i, # Convert to cents
        currency: 'usd',
        metadata: {
          user_id: user.id,
          subscription_plan_id: subscription_plan.id
        }
      )
    
      render json: {
        client_secret: payment_intent.client_secret
      }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Subscription plan not found' }, status: :not_found
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
    
    # POST /api/v1/user_subscriptions/confirm
    # Step 2: Confirms the payment and creates the subscription
    def confirm
      user = @current_user # We use @current_user instead of current_user
      subscription_plan = SubscriptionPlan.find(params[:plan_id])
      
      # Optionally: verify payment status via Stripe API here
      # payment_intent_id = params[:payment_intent_id]
      # payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      # return unless payment_intent.status == 'succeeded'
  
      user_subscription = UserSubscription.new(
        user: user,
        subscription_plan: subscription_plan,
        start_date: Date.today,
        end_date: Date.today + subscription_plan.duration_months,
        status: :active
      )
  
      if user_subscription.save
        render json: user_subscription, status: :created
      else
        render json: user_subscription.errors, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Subscription plan not found' }, status: :not_found
    end
  
    private
  
    # JWT Authorization Logic
   # JWT Authorization Logic
   def authorize_request
    header = request.headers['Authorization']
    if header.present?
      token = header.split(' ').last
      Rails.logger.info("Received token: #{token}")
  
      begin
        decoded = JsonWebToken.decode(token)
        @current_user = User.find(decoded['user_id'])
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("User not found: #{e.message}")
        render json: { errors: ['Invalid or missing token'] }, status: :unauthorized
      rescue JWT::DecodeError => e
        Rails.logger.error("JWT DecodeError: #{e.message}")
        render json: { errors: ['Invalid token'] }, status: :unauthorized
      end
    else
      Rails.logger.error("Authorization header missing")
      render json: { errors: ['Missing token'] }, status: :unauthorized
    end
  end
  
  
end
  