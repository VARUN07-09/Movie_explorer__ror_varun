require 'httparty'
require 'googleauth'

class FcmService
  def initialize
    @credentials = Rails.application.credentials.fcm
    raise 'FCM credentials not found in credentials.yml' unless @credentials

    Rails.logger.info "FCM Project ID: #{@credentials[:project_id]}"
    Rails.logger.info "FCM Client Email: #{@credentials[:client_email][0..20]}..."

    temp_json_file = Tempfile.new('fcm_service_account.json')
    temp_json_file.write(@credentials.to_json)
    temp_json_file.rewind

    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: temp_json_file,
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    )
    raise 'Failed to initialize Google Auth credentials' if @authorizer.nil?

    
    temp_json_file.close
    temp_json_file.unlink
  end

  def send_notification(device_tokens, title, body, data = {})
    tokens = Array(device_tokens).map(&:to_s).reject do |token|
      if token.strip.empty?
        Rails.logger.warn("Rejected empty FCM token")
        true
      elsif token.include?('test')
        Rails.logger.warn("Rejected FCM token containing 'test': #{token}")
        true
      else
        false
      end
    end

    return { status_code: 200, body: 'No valid device tokens' } if tokens.empty?

   
    access_token = @authorizer.fetch_access_token!['access_token']
    raise 'Failed to fetch OAuth2 access token' if access_token.nil? || access_token.empty?

    
    url = "https://fcm.googleapis.com/v1/projects/#{@credentials[:project_id]}/messages:send"

    payload = {
      message: {
        notification: {
          title: title.to_s,
          body: body.to_s
        },
        data: data.transform_values(&:to_s)
      }
    }

    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json'
    }

    begin
      responses = tokens.map do |token|
        payload[:message][:token] = token
        Rails.logger.info "Sending FCM to token: #{token[0..20]}... with payload: #{payload.inspect}"

        response = HTTParty.post(
          url,
          body: payload.to_json,
          headers: headers
        )

        Rails.logger.info "Raw FCM Response: #{response.inspect}"
        {
          status_code: response.code,
          body: response.body
        }
      end

      status_code = responses.all? { |r| r[:status_code]&.to_i == 200 } ? 200 : 500
      body = responses.map { |r| r[:body] || "No response body" }.join("; ")

      {
        status_code: status_code,
        body: body,
        response: responses
      }
    rescue StandardError => e
      Rails.logger.error "FCM Error: #{e.message}\n#{e.backtrace.join("\n")}"
      { status_code: 500, body: e.message }
    end
  end
end