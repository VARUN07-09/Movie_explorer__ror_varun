module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authorize_request, except: [:login, :signup]

      def toggle_notifications
        new_status = params[:notifications_enabled] == "true" || params[:notifications_enabled] == true
        if @current_user.update(notifications_enabled: new_status)
          render json: { message: "Notification preference updated", notifications_enabled: @current_user.notifications_enabled }, status: :ok
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def signup
        user = User.new(user_params)
        if user.save
          token = encode_token({ user_id: user.id })
          render json: { user: user.as_json(only: [:id, :name, :email, :role]), token: token }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:auth][:email])
        if user&.authenticate(params[:auth][:password])
          token = encode_token({ user_id: user.id })
          render json: { user: user.as_json(only: [:id, :name, :email, :role]), token: token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def encode_token(payload)
        JWT.encode(payload, Rails.application.credentials.secret_key_base)
      end
    end
  end
end