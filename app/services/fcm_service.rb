class FcmService
    def initialize
      @fcm = FCM.new(ENV['FCM_SERVER_KEY'] || Rails.application.credentials.dig(:fcm, :server_key))
    end
  
    def send_notification(token, title, body)
      options = {
        notification: {
          title: title,
          body: body
        }
      }
      @fcm.send([token], options)
    end
  end
  