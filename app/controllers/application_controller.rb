class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  
    private
  
    # def authenticate_admin_user!
    #   unless current_admin_user
    #     flash[:alert] = "You must be an admin to access this section."
    #     redirect_to "/" 
    #   end
    # end
  
    # def current_admin_user
    #   user_id = session[:user_id]
    #   return nil unless user_id
  
    #   user = User.find_by(id: user_id)
    #   return user if user&.admin?
    # end

    # # Overriding the default behavior of `current_user` in ActiveAdmin.
    # def current_user
    #   current_admin_user # In ActiveAdmin, we want to use the admin version of the user
    # end
    def authorize_request
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      Rails.logger.debug "Authorization header: #{header}"
      Rails.logger.debug "Token: #{token}"
  
      begin
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]

        Rails.logger.debug "Decoded payload: #{decoded}"
        @current_user = User.find(decoded['user_id'])
      rescue JWT::DecodeError => e
        render json: { errors: 'Invalid token' }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'User not found' }, status: :unauthorized
      end
    end
  end
  