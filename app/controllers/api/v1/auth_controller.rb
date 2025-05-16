module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:signup, :login, :update_profile_picture, :toggle_notifications, :update_device_token, :create_stripe_customer]
      before_action :authorize_request, except: [:signup, :login]

      def show
        render json: { user: @current_user.as_json(only: [:id, :name, :email, :role], methods: :profile_picture_url) }, status: :ok
      end

      def update_profile_picture
        unless params[:profile_picture].present?
          return render json: { errors: ['Profile picture is required'] }, status: :unprocessable_entity
        end

        @current_user.profile_picture.attach(params[:profile_picture])
        if @current_user.save
          render json: {
            user: @current_user.as_json(only: [:id, :name, :email, :role], methods: :profile_picture_url),
            message: 'Profile picture updated successfully'
          }, status: :ok
        else
          render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def toggle_notifications
        unless params[:notifications_enabled].in?([true, false])
          return render json: { errors: ['notifications_enabled must be true or false'] }, status: :unprocessable_entity
        end

        @current_user.update!(notifications_enabled: params[:notifications_enabled])
        render json: { message: 'Notification preference updated', notifications_enabled: @current_user.notifications_enabled }, status: :ok
      end

      def update_device_token
        unless params[:device_token].present?
          return render json: { errors: ['device_token is required'] }, status: :unprocessable_entity
        end

        @current_user.update!(device_token: params[:device_token])
        render json: { message: 'Device token updated' }, status: :ok
      end

      def signup
        user = User.new(user_params)
        if user.save
          render json: { user: user.as_json(only: [:id, :name, :email, :role])}, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:auth][:email]&.downcase)
        if user&.authenticate(params[:auth][:password])
          token = encode_token(user.id)
          render json: { user: user.as_json(only: [:id, :name, :email, :role]), token: token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def create_stripe_customer
        begin
          customer = Stripe::Customer.create(
            email: @current_user.email,
            name: @current_user.name
          )
          render json: { message: 'Stripe customer created successfully', customer_id: customer.id }, status: :created
        rescue Stripe::StripeError => e
          render json: { error: "Stripe error: #{e.message}" }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def encode_token(user_id)
        JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
      end
    end
  end
end 