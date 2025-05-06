module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user, except: [:index, :show]
  end

  private

  def authenticate_user
    auth_header = request.headers['Authorization']
    unless auth_header&.match?(/\ABearer\s/)
      render json: { error: 'Authorization header missing or invalid' }, status: :unauthorized
      return
    end

    token = auth_header.split(' ').last
    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
      @current_user = User.find_by(id: decoded.first['user_id'])
      unless @current_user
        render json: { error: 'User not found' }, status: :unauthorized
        return
      end
    rescue JWT::ExpiredSignature
      render json: { error: 'Token has expired' }, status: :unauthorized
    rescue JWT::DecodeError
     Hum render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end