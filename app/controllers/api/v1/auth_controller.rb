module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_with_token!, except: [:login, :signup]
      before_action :authenticate_user!, except: [:login, :signup]  # Ensure that the user is authenticated before accessing these actions

      # Update FCM token
      def update_fcm_token
        if current_user.update(fcm_token: params[:fcm_token])
          render json: { message: "FCM token updated successfully" }, status: :ok
        else
          render json: { error: "Failed to update FCM token" }, status: :unprocessable_entity
        end
      end

      # Update notification preferences (e.g., turn notifications on/off)
      def update_notification_preferences
        current_user.update!(notification_params)
        render json: { success: true }
      end

      # User signup action
      def signup
        user = User.new(user_params)
        if user.save
          token = encode_token({ user_id: user.id })
          render json: { user: user.as_json(only: [:id, :name, :email, :role]) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # User login action
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

      # Strong parameters for user signup
      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      # Strong parameters for updating notification preferences
      def notification_params
        params.permit(:notify_on_new_movie)
      end

      # JWT token encoding method
      def encode_token(payload)
        JWT.encode(payload, Rails.application.secret_key_base)
      end
    end
  end
end
