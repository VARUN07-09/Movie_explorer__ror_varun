# app/controllers/concerns/authenticable.rb
module Authenticable
    extend ActiveSupport::Concern
  
    included do
      before_action :authenticate_user
    end
  
    private
  
    def authenticate_user
      token = request.headers['Authorization']&.split(' ')&.last
      begin
        decoded = JWT.decode(token, 'your_secret_key', true, algorithm: 'HS256')
        @current_user = User.find(decoded[0]['user_id'])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  
    def current_user
      @current_user
    end
  end