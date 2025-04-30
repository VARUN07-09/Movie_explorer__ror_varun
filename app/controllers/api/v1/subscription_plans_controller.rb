module Api
  module V1
    class SubscriptionPlansController < ApplicationController
      # before_action :authenticate_user!

      def index
        plans = SubscriptionPlan.all
        render json: plans
      end

      def show
        plan = SubscriptionPlan.find(params[:id])
        render json: plan
      end
    end
  end
end
