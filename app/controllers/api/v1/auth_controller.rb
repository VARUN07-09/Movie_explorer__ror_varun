module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token

      # User signup action
      def signup
        user = User.new(user_params)
        if user.save
          token = encode_token({ user_id: user.id })
          render json: { user: user.as_json(only: [:id, :name, :email, :role])}, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # User login action
      def login
        user = User.find_by(email: params[:auth][:email])  # Accessing the nested 'auth' key
        if user&.authenticate(params[:auth][:password])  # Check if password is correct
          token = encode_token({ user_id: user.id })
          render json: { user: user.as_json(only: [:id, :name, :email, :role]), token: token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      private

      # Strong parameters for signup
      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      # JWT token encoding method
      def encode_token(payload)
        JWT.encode(payload, 'your_secret_key')  # Use a secure secret key here
      end
    end
  end
end
