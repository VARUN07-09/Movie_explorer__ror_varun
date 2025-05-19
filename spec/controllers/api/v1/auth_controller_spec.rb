require 'rails_helper'

def encode_token(user_id)
  JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
end

RSpec.describe Api::V1::AuthController, type: :controller do
  let(:user) { create(:user, email: "test#{Time.now.to_i}@example.com") }
  let(:json_response) { JSON.parse(response.body) }

  describe 'POST /api/v1/signup' do
    let(:valid_params) do
      {
        user: {
          name: 'Test User',
          email: "newuser#{Time.now.to_i}@example.com",
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    context 'creates a new user' do
      it 'creates the user and returns status 201' do
        post :signup, params: valid_params
        expect(response).to have_http_status(:created)
        expect(json_response['user']['email']).to eq(valid_params[:user][:email])
        expect(json_response['user']['name']).to eq('Test User')
        expect(json_response['user']['id']).to be_present
        expect(json_response['user']['role']).to eq('user')
      end
    end

    context 'fails with missing required fields' do
      it 'returns error for missing name' do
        post :signup, params: { user: valid_params[:user].except(:name) }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Name can't be blank")
      end
    end

    context 'fails with invalid input' do
      it 'returns error for invalid email format' do
        post :signup, params: { user: valid_params[:user].merge(email: 'invalid_email') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include('Email is invalid')
      end
    end
  end

  describe 'POST /api/v1/login' do
    let(:valid_params) { { auth: { email: user.email, password: 'password123' } } }

    context 'logs in valid user' do
      it 'logs in and returns user data' do
        post :login, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['token']).to be_present
      end
    end

    context 'rejects invalid login' do
      it 'returns error for invalid email' do
        post :login, params: { auth: { email: 'invalid@example.com', password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'GET /api/v1/user' do
    context 'returns current user info' do
      it 'returns the current user' do
        allow(controller).to receive(:current_user).and_return(user)
        get :show
        expect(response).to have_http_status(:ok)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']['name']).to eq(user.name)
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context 'fails without authentication' do
      it 'returns unauthorized without token' do
        get :show
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Authorization header missing or invalid')
      end
    end
  end

  describe 'POST /api/v1/update_profile_picture' do
    let(:jpg_file) { fixture_file_upload('spec/fixtures/sample.jpg', 'image/jpeg') }

    context 'uploads profile picture' do
      it 'uploads a new profile picture' do
        allow(controller).to receive(:current_user).and_return(user)
        post :update_profile_picture, params: { profile_picture: jpg_file }
        expect(response).to have_http_status(:ok)
        expect(json_response['user']['profile_picture_url']).to be_present
        expect(json_response['message']).to eq('Profile picture updated successfully')
      end
    end
  end

  describe 'POST /api/v1/toggle_notifications' do
    context 'enables notifications' do
      it 'enables notifications successfully' do
        allow(controller).to receive(:current_user).and_return(user)
        user.update(notifications_enabled: false)
        post :toggle_notifications, params: { notifications_enabled: true }
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Notification preference updated')
        expect(json_response['notifications_enabled']).to eq(true)
      end
    end
  end

  describe 'POST /api/v1/update_device_token' do
    context 'updates device token' do
      it 'updates device token successfully' do
        allow(controller).to receive(:current_user).and_return(user)
        post :update_device_token, params: { device_token: 'new_token_123' }
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Device token updated')
      end
    end
  end
end