# app/controllers/api/v1/notifications_controller.rb
module Api
  module V1
    class NotificationsController < ApplicationController
      include Authenticable
      skip_before_action :verify_authenticity_token 
      before_action :authenticate_user
      before_action :authorize_admin_or_supervisor!

      def test
        fcm = FCM.new(ENV['FCM_SERVER_KEY'])
        user = current_user
        unless user.fcm_token
          return render json: { error: 'No FCM token for user' }, status: :unprocessable_entity
        end

        message = {
          notification: {
            title: "Test Notification",
            body: "This is a test push notification from the backend!",
            icon: nil
          },
          data: {
            test: "true",
            click_action: "#{ENV['FRONTEND_URL']}/dashboard"
          },
          webpush: {
            fcm_options: {
              link: "#{ENV['FRONTEND_URL']}/dashboard"
            }
          }
        }

        response = fcm.send([user.fcm_token], message)
        Rails.logger.info "FCM Test Notification Response: #{response.inspect}"

        if response[:status_code] == 200 && response[:response] == 'success'
          render json: { message: "Test notification sent successfully" }, status: :ok
        else
          render json: { error: "Failed to send test notification: #{response[:body]}" }, status: :unprocessable_entity
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