module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authorize_request, except: [:login, :signup]

      def update_device_token
        token = params[:device_token] || params[:fcm_token] || params.dig(:auth, :fcm_token)
        Rails.logger.info "Updating device token: #{token}"
        if token.blank?
          render json: { errors: "Device token is required" }, status: :unprocessable_entity
          return
        end
        if @current_user.update(device_token: token)
          render json: { message: "Device token updated successfully" }, status: :ok
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def toggle_notifications
        Rails.logger.info "Params: #{params.inspect}"
        new_status = params[:notifications_enabled] == "true" || params[:notifications_enabled] == true ||
                     params[:notify_on_new_movie] == "true" || params[:notify_on_new_movie] == true ||
                     params.dig(:auth, :notify_on_new_movie) == "true" || params.dig(:auth, :notify_on_new_movie) == true
        Rails.logger.info "New Notification Status: #{new_status.inspect}"
        if @current_user.update(notifications_enabled: new_status)
          if @current_user.notifications_enabled && @current_user.device_token
            begin
              fcm_service = FcmService.new
              response = fcm_service.send_notification(
                @current_user.device_token,
                "Notifications #{new_status ? 'Enabled' : 'Disabled'}",
                "You have #{new_status ? 'turned on' : 'turned off'} notifications for Movie Explorer."
              )
              Rails.logger.info "FCM Response: #{response.inspect}"
            rescue StandardError => e
              Rails.logger.error "FCM Notification Failed: #{e.message}"
            end
          end
          render json: { message: "Notification preference updated", notifications_enabled: @current_user.notifications_enabled }, status: :ok
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def signup
        user = User.new(user_params)
        if user.save
          token = encode_token({ user_id: user.id })
          render json: { user: user.as_json(only: [:id, :name, :email, :role]) }, status: :created
        else
          render json: { errors: user.errors

System: .full_messages }, status: :unprocessable_entity
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

      def device_token_params
        params.permit(:device_token, :fcm_token, auth: [:fcm_token])
      end

      def encode_token(payload)
        JWT.encode(payload, Rails.application.credentials.secret_key_base)
      end
    end
  end
end