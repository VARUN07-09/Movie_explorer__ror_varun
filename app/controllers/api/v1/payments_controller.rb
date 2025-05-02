module Api
  module V1
    class PaymentsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        # Find the subscription plan based on the provided plan_id
        plan = SubscriptionPlan.find_by(id: params[:plan_id])
        
        # Return an error if the plan isn't found
        return render json: { error: 'Plan not found' }, status: :not_found unless plan

        # Create a Stripe Checkout Session
        begin
          session = Stripe::Checkout::Session.create(
            payment_method_types: ['card'],
            line_items: [{
              price_data: {
                currency: 'usd',
                product_data: {
                  name: plan.name
                },
                unit_amount: (plan.price * 100).to_i  # Convert price to cents
              },
              quantity: 1
            }],
            mode: 'payment',
            success_url: "#{ENV['FRONTEND_URL']}/payment-success?session_id={CHECKOUT_SESSION_ID}",
            cancel_url: "#{ENV['FRONTEND_URL']}/payment-cancelled"
          )

          # Respond with the session ID and the URL to redirect the user
          render json: { id: session.id, url: session.url }
        rescue Stripe::StripeError => e
          # Catch any errors from the Stripe API and return an appropriate response
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
