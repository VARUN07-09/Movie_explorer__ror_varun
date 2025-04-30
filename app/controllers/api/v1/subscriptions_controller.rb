module Api
    module V1
      class SubscriptionsController < ApplicationController
        before_action :authenticate_user
        before_action :set_subscription, only: [:show, :update, :destroy]
  
        def index
          @subscriptions = current_user.subscriptions
          render json: @subscriptions
        end
  
        def show
          render json: @subscription
        end
  
        def create
          @subscription = current_user.subscriptions.new(subscription_params)
          if @subscription.save
            render json: @subscription, status: :created
          else
            render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        def update
          if @subscription.user_id == current_user.id && @subscription.update(subscription_params)
            render json: @subscription
          else
            render json: { errors: ["Unauthorized or invalid data"] }, status: :unauthorized
          end
        end
  
        def destroy
          if @subscription.user_id == current_user.id
            @subscription.destroy
            head :no_content
          else
            render json: { errors: ["Unauthorized"] }, status: :unauthorized
          end
        end
  
        private
  
        def set_subscription
          @subscription = Subscription.find(params[:id])
        end
  
        def subscription_params
          params.require(:subscription).permit(:plan_type, :status, :start_date, :end_date)
        end
      end
    end
  end
  