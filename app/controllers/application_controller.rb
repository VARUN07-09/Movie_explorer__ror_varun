class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header&.match?(/\ABearer\s/)
    Rails.logger.debug "Authorization header: #{header}"
    Rails.logger.debug "Token: #{token}"

    unless token
      render json: { error: 'Authorization header missing or invalid' }, status: :unauthorized
      return
    end

    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')[0]
      Rails.logger.debug "Decoded payload: #{decoded}"
      @current_user = User.find(decoded['user_id'])
    rescue JWT::ExpiredSignature
      render json: { error: 'Token has expired' }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end