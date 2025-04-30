# app/services/json_web_token.rb
class JsonWebToken
    JWT_SECRET_KEY = Rails.application.credentials.jwt_secret_key || ENV['JWT_SECRET_KEY']

    # Encode the payload with a secret key
    def self.encode(payload)
      # Use Rails credentials to get the secret key
      JWT.encode(payload, Rails.application.credentials.jwt_secret_key) # Or ENV['JWT_SECRET_KEY']
    end
  
    # Decode the token and return the payload
    def self.decode(token)
        secret = Rails.application.credentials.jwt_secret_key || ENV['JWT_SECRET_KEY']
        Rails.logger.info("Decoding token with secret: #{secret.present? ? 'present' : 'missing'}")
        decoded = JWT.decode(token, secret)[0]
        HashWithIndifferentAccess.new(decoded)
      rescue JWT::DecodeError => e
        raise JWT::DecodeError, "Invalid token: #{e.message}"
      end
      
  end
  