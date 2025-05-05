module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user, except: [:index, :show] # Default authentication for all actions except index and show
  end

  private

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    unless token
      render json: { error: 'Token missing' }, status: :unauthorized
      return
    end

    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
      @current_user_id = decoded.first['user_id']
      @current_user = User.find_by(id: @current_user_id)
      unless @current_user
        render json: { error: 'User not found' }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end