module Api
    module V1
      class UserSubscriptionsController < ApplicationController
        skip_before_action :verify_authenticity_token, only: [:create, :success, :cancel]
        before_action :authorize_request, only: [:create, :index, :status]
  
        def index
          subscriptions = @current_user ? @current_user.user_subscriptions : UserSubscription.none
          render json: subscriptions.as_json(
            only: [:id, :start_date, :end_date, :status, :expires_at, :plan_type]
          ), status: :ok
        end
  
        def create
          plan_type = params[:plan_type]
  
          stripe_price_id = {
            "1-day" => ENV['One_DAY_ID'],
            "1-month" => ENV['One_MONTH_ID'],
            "3-months" => ENV['Three_MONTHS_ID']
          }[plan_type]
  
          unless stripe_price_id
            return render json: { error: 'Invalid or missing plan_type' }, status: :bad_request
          end
  
          begin
            existing_subscription = @current_user.user_subscriptions.find_by(status: :active)
            stripe_customer_id = existing_subscription&.stripe_customer_id || Stripe::Customer.create(email: @current_user.email).id
  
            session = Stripe::Checkout::Session.create(
              customer: stripe_customer_id,
              payment_method_types: ['card'],
              line_items: [{ price: stripe_price_id, quantity: 1 }],
              mode: 'payment',
              metadata: {
                user_id: @current_user.id,
                plan_type: plan_type
              },
              success_url: "https://movie-explorer-puce-five.vercel.app/success",
              cancel_url: "http://localhost:3000/api/v1/user_subscriptions/cancel"
            )
  
            render json: { session_id: session.id, url: session.url }, status: :ok
          rescue Stripe::StripeError => e
            Rails.logger.error("Stripe error: #{e.message}")
            render json: { error: "Stripe error: #{e.message}" }, status: :unprocessable_entity
          end
        end
  
        def success
          session = Stripe::Checkout::Session.retrieve(params[:session_id])
          plan_type = session.metadata['plan_type']
  
          duration_days = case plan_type
                          when '1-day' then 1
                          when '1-month' then 30
                          when '3-months' then 90
                          else 30
                          end
  
          user = User.find_by(id: session.metadata['user_id'])
          return render json: { error: 'User not found' }, status: :unprocessable_entity unless user
  
          start_date = Date.today
          end_date = start_date + duration_days.days
          user.user_subscriptions.update_all(status: "cancelled")

  
          user.user_subscriptions.create!(
            plan_type: plan_type,
            start_date: start_date,
            end_date: end_date,
            status: :active,
            stripe_customer_id: session.customer,
            stripe_subscription_id: session.payment_intent,
            expires_at: end_date
          )
  
          render json: { message: 'Subscription created successfully' }, status: :ok
        end
  
        def cancel
          render json: { message: 'Payment cancelled' }, status: :ok
        end
  
        def status
          subscription = @current_user.user_subscriptions.find_by(status: :active)
  
          if subscription.nil?
            return render json: { error: 'No active subscription found' }, status: :not_found
          end
  
          if subscription.expires_at.present? && subscription.expires_at < Time.current
            subscription.update!(
              plan_type: '1-day',
              start_date: Date.today,
              end_date: Date.today + 1.day,
              expires_at: Date.today + 1.day
            )
            render json: { plan_type: '1-day', message: 'Expired. Downgraded to 1-day.' }, status: :ok
          else
            render json: { plan_type: subscription.plan_type }, status: :ok
          end
        end
      end
    end
  end
  