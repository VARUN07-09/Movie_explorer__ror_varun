module Api
    module V1
      class PaymentsController < ApplicationController
        # before_action :authenticate_user!
        skip_before_action :verify_authenticity_token
  
        def create
          plan = SubscriptionPlan.find(params[:plan_id])
          
          session = Stripe::Checkout::Session.create(
            payment_method_types: ['card'],
            line_items: [{
              price_data: {
                currency: 'usd',
                product_data: {
                  name: plan.name
                },
                unit_amount: (plan.price * 100).to_i
              },
              quantity: 1
            }],
            mode: 'payment',
            success_url: "#{ENV['FRONTEND_URL']}/payment-success?session_id={CHECKOUT_SESSION_ID}",
            cancel_url: "#{ENV['FRONTEND_URL']}/payment-cancelled"
          )
  
          render json: { id: session.id }
        end
      end
    end
  end
  