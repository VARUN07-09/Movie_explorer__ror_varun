# app/controllers/api/v1/notifications_controller.rb
module Api
  module V1
    class NotificationsController < ApplicationController
      include Authenticable
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user
      before_action :authorize_admin_or_supervisor!

      def test
        # Get Firebase Server Key from Rails credentials
        fcm = FCM.new(Rails.application.credentials.fcm[:private_key])  # Firebase private key is passed from the credentials

        user = current_user

        unless user.device_token.present?
          Rails.logger.warn "User ##{user.id} has no device token"
          return render json: { error: 'No device token for user' }, status: :unprocessable_entity
        end

        message = {
          notification: {
            title: "Test Notification",
            body: "This is a test push notification from the backend!",
            icon: nil
          },
          data: {
            test: "true",
            click_action: "#{Rails.application.credentials.fcm[:client_email]}"
          },
          webpush: {
            fcm_options: {
              link: "#{Rails.application.credentials.fcm[:client_email]}"
            }
          }
        }

        # Send push notification
        response = fcm.send([user.device_token], message)
        Rails.logger.info "FCM Test Notification Response: #{response.inspect}"

        if response[:status_code] == 200 && response[:response] == 'success'
          render json: { message: "Test notification sent successfully" }, status: :ok
        else
          render json: { error: "Failed to send test notification", details: response[:body] }, status: :unprocessable_entity
        end
      end

      private

      def authorize_admin_or_supervisor!
        unless current_user&.admin? || current_user&.supervisor?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
