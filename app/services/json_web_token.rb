class JsonWebToken
  JWT_SECRET_KEY = Rails.application.credentials.jwt_secret_key || ENV['JWT_SECRET_KEY']
  DEFAULT_EXPIRY = 24.hours 

  def self.encode(payload, expiry = DEFAULT_EXPIRY)
    payload = payload.dup
    payload[:exp] = expiry.from_now.to_i
    JWT.encode(payload, Rails.application.credentials.jwt_secret_key)
  end

  def self.decode(token)
    secret = Rails.application.credentials.jwt_secret_key || ENV['JWT_SECRET_KEY']
    Rails.logger.info("Decoding token with secret: #{secret.present? ? 'present' : 'missing'}")
    decoded = JWT.decode(token, secret)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, "Invalid token: #{e.message}"
  end
end