require 'rails_helper'

# Helper to generate JWT tokens, mimicking controller's encode_token
def encode_token(user_id)
  JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
end

RSpec.describe Api::V1::AuthController, type: :controller do
  let(:user) { create(:user) } # Use factory without hardcoding email

  describe 'POST /api/v1/signup' do
    context 'creates a new user' do
      it 'creates the user and returns status 201' do
        post :signup, params: { user: { name: 'Test User', email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' } }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['user']['email']).to eq('newuser@example.com')
      end
    end

    context 'fails when passwords do not match' do
      it 'returns error when passwords do not match' do
        post :signup, params: { user: { name: 'Test User', email: 'newuser@example.com', password: 'password123', password_confirmation: 'differentpassword' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Password confirmation doesn't match Password")
      end
    end
  end

  describe 'POST /api/v1/login' do
    context 'logs in valid user' do
      it 'logs in and returns user data' do
        post :login, params: { auth: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['user']['email']).to eq(user.email)
        expect(JSON.parse(response.body)['token']).to be_present
      end
    end

    context 'rejects invalid login' do
      it 'returns error for invalid login' do
        post :login, params: { auth: { email: 'invalid@example.com', password: 'wrongpassword' } }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'GET /api/v1/user' do
    context 'returns current user info' do
      it 'returns the current user' do
        token = encode_token(user.id) # Use helper method
        request.headers['Authorization'] = "Bearer #{token}"
        get :show # Controller uses 'show', not 'user'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['user']['email']).to eq(user.email)
      end
    end
  end

  describe 'POST /api/v1/update_profile_picture' do
    # context 'uploads profile picture' do
    #   it 'uploads a new profile picture' do
    #     token = encode_token(user.id)
    #     request.headers['Authorization'] = "Bearer #{token}"
    #     post :update_profile_picture, params: { profile_picture: fixture_file_upload('spec/fixtures/profile_picture.jpg', 'image/jpeg') }
    #     expect(response).to have_http_status(:ok)
    #     expect(JSON.parse(response.body)['user']['profile_picture_url']).to be_present
    #   end
    # end

    context 'returns error when no file is attached' do
      it 'returns error when no file is attached' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :update_profile_picture
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Profile picture is required')
      end
    end
  end

  describe 'POST /api/v1/toggle_notifications' do
    context 'returns error if invalid value' do
      it 'returns error if value is invalid' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_notifications, params: { notifications_enabled: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('notifications_enabled must be true or false')
      end
    end
  end

  describe 'POST /api/v1/update_device_token' do
    context 'updates device token' do
      it 'updates device token successfully' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :update_device_token, params: { device_token: 'new_token_123' }
        expect(response).to have_http_status(:ok)
        expect(user.reload.device_token).to eq('new_token_123')
      end
    end

    context 'returns error if token is missing' do
      it 'returns error if no token is provided' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :update_device_token
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('device_token is required')
      end
    end
  end

  describe 'POST /api/v1/create_stripe_customer' do
    context 'creates stripe customer' do
      it 'creates a customer in Stripe' do
        allow(Stripe::Customer).to receive(:create).with(email: user.email, name: user.name).and_return(double(id: 'cus_123'))
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :create_stripe_customer
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['customer_id']).to eq('cus_123')
      end
    end
  end
end