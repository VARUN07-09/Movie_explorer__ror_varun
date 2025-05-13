require 'rails_helper'

def encode_token(user_id)
  JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
end

RSpec.describe Api::V1::AuthController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST /api/v1/signup' do
    let(:valid_params) do
      {
        user: {
          name: 'Test User',
          email: 'newuser@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    context 'creates a new user' do
      it 'creates the user and returns status 201' do
        post :signup, params: valid_params
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq('newuser@example.com')
        expect(json['user']['name']).to eq('Test User')
        expect(json['user']['id']).to be_present
        expect(json['user']['role']).to eq('user')
      end
    end

    context 'fails with missing required fields' do
      it 'returns error for missing name' do
        post :signup, params: { user: valid_params[:user].except(:name) }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end

      it 'returns error for missing email' do
        post :signup, params: { user: valid_params[:user].except(:email) }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Email can't be blank")
      end

      it 'returns error for missing password' do
        post :signup, params: { user: valid_params[:user].except(:password) }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Password can't be blank")
      end

      it 'creates user despite missing password_confirmation' do
        post :signup, params: { user: valid_params[:user].except(:password_confirmation) }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq('newuser@example.com')
      end
    end

    context 'fails with invalid input' do
      it 'returns error for invalid email format' do
        post :signup, params: { user: valid_params[:user].merge(email: 'invalid_email') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Email is invalid')
      end

      it 'returns error for password mismatch' do
        post :signup, params: { user: valid_params[:user].merge(password_confirmation: 'different') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Password confirmation doesn't match Password")
      end

      it 'returns error for short password' do
        post :signup, params: { user: valid_params[:user].merge(password: 'short', password_confirmation: 'short') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Password is too short (minimum is 8 characters)')
      end

      it 'returns error for duplicate email' do
        create(:user, email: 'existing@example.com')
        post :signup, params: { user: valid_params[:user].merge(email: 'existing@example.com') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Email has already been taken')
      end
    end
  end

  describe 'POST /api/v1/login' do
    let(:valid_params) { { auth: { email: user.email, password: 'password123' } } }

    context 'logs in valid user' do
      it 'logs in and returns user data' do
        post :login, params: valid_params
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq(user.email)
        expect(json['user']['name']).to eq(user.name)
        expect(json['user']['id']).to be_present
        expect(json['user']['role']).to eq('user')
      end
    end

    context 'rejects invalid login' do
      it 'returns error for invalid email' do
        post :login, params: { auth: { email: 'invalid@example.com', password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end

      it 'returns error for wrong password' do
        post :login, params: { auth: { email: user.email, password: 'wrongpassword' } }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end

    context 'fails with missing or invalid input' do
      it 'returns error for missing email' do
        post :login, params: { auth: { password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end

      it 'returns error for missing password' do
        post :login, params: { auth: { email: user.email } }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'GET /api/v1/user' do
    context 'returns current user info' do
      it 'returns the current user' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        get :show
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq(user.email)
        expect(json['user']['name']).to eq(user.name)
        expect(json['user']['id']).to be_present
        expect(json['user']['role']).to eq('user')
        expect(json['user']['profile_picture_url']).to be_nil
      end
    end

    context 'fails without authentication' do
      it 'returns unauthorized without token' do
        get :show
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
      end
    end

    context 'fails with invalid token' do
      it 'returns unauthorized with invalid token' do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :show
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid token: Not enough or too many segments')
      end

      it 'returns unauthorized with expired token' do
        expired_token = JWT.encode({ user_id: user.id, exp: 1.hour.ago.to_i }, Rails.application.credentials.secret_key_base)
        request.headers['Authorization'] = "Bearer #{expired_token}"
        get :show
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Token has expired')
      end
    end
  end

  describe 'POST /api/v1/update_profile_picture' do
    # Helper to create and clean up Tempfile safely
    def with_tempfile(filename, content, content_type)
      file = Tempfile.new(filename)
      file.write(content)
      file.rewind
      uploaded_file = fixture_file_upload(file.path, content_type)
      yield uploaded_file
    ensure
      file.close
      begin
        File.unlink(file.path) if File.exist?(file.path)
      rescue Errno::EACCES
        Rails.logger.warn("Failed to unlink tempfile: #{file.path}")
      end
    end

    context 'uploads profile picture' do
      it 'uploads a new profile picture' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        with_tempfile(['profile_picture', '.jpg'], 'fake image content', 'image/jpeg') do |uploaded_file|
          post :update_profile_picture, params: { profile_picture: uploaded_file }
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['user']['profile_picture_url']).to be_present
          expect(json['user']['id']).to eq(user.id)
          expect(json['user']['email']).to eq(user.email)
          expect(json['user']['name']).to eq(user.name)
          expect(json['user']['role']).to eq('user')
          expect(json['message']).to eq('Profile picture updated successfully')
          expect(user.reload.profile_picture).to be_attached
        end
      end
    end

    context 'fails with invalid input' do
      it 'returns error for missing file' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :update_profile_picture
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Profile picture is required')
      end

      it 'accepts non-image file without validation' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        with_tempfile(['profile_picture', '.txt'], 'text content', 'text/plain') do |uploaded_file|
          post :update_profile_picture, params: { profile_picture: uploaded_file }
          expect(response).to have_http_status(:ok)
          expect(user.reload.profile_picture).to be_attached
        end
      end

      it 'accepts oversized file without validation' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        with_tempfile(['profile_picture', '.jpg'], 'a' * 6.megabytes, 'image/jpeg') do |uploaded_file|
          post :update_profile_picture, params: { profile_picture: uploaded_file }
          expect(response).to have_http_status(:ok)
          expect(user.reload.profile_picture).to be_attached
        end
      end
    end

    context 'fails without authentication' do
      it 'returns unauthorized without token' do
        with_tempfile(['profile_picture', '.jpg'], 'fake image content', 'image/jpeg') do |uploaded_file|
          post :update_profile_picture, params: { profile_picture: uploaded_file }
          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
        end
      end
    end
  end

  describe 'POST /api/v1/toggle_notifications' do
    context 'enables notifications' do
      it 'returns error due to validation' do
        user.update(notifications_enabled: false)
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_notifications, params: { notifications_enabled: true }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('notifications_enabled must be true or false')
      end
    end

    context 'disables notifications' do
      it 'returns error due to validation' do
        user.update(notifications_enabled: true)
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_notifications, params: { notifications_enabled: false }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('notifications_enabled must be true or false')
      end
    end

    context 'fails with invalid input' do
      it 'returns error for invalid value' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_notifications, params: { notifications_enabled: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('notifications_enabled must be true or false')
      end
    end

    context 'fails without authentication' do
      it 'returns unauthorized without token' do
        post :toggle_notifications, params: { notifications_enabled: true }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
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
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Device token updated')
        expect(user.reload.device_token).to eq('new_token_123')
      end
    end

    context 'fails with invalid input' do
      it 'returns error for missing token' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :update_device_token
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('device_token is required')
      end

      it 'returns error for empty token' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :update_device_token, params: { device_token: '' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('device_token is required')
      end
    end

    context 'fails without authentication' do
      it 'returns unauthorized without token' do
        post :update_device_token, params: { device_token: 'new_token_123' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
      end
    end
  end

  describe 'authentication filters' do
    it 'handles malformed JWT token' do
      request.headers['Authorization'] = 'Bearer malformed.token.here'
      get :show
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid token: Invalid segment encoding')
    end
  end
end