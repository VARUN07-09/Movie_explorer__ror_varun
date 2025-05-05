module Api
    module V1
      class NotificationsController < ApplicationController
        def test
          user = User.find(params[:user_id])
          if user.fcm_token.present?
            FcmService.new.send_notification(user.fcm_token, "Test Notification", "This is a test.")
            render json: { message: "Notification sent" }
          else
            render json: { error: "User has no FCM token" }, status: :unprocessable_entity
          end
        end
      end
    end
  end
  