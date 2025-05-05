# app/controllers/concerns/authenticatable.rb
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_token!
  end

  def authenticate_with_token!
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload['user_id'])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
