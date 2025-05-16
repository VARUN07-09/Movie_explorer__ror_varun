require 'rails_helper'

RSpec.describe Api::V1::UserSubscriptionsController, type: :controller do
  before do
    request.headers['Content-Type'] = 'application/json'
    request.headers.merge!(auth_headers)
  end

  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:auth_headers) { { 'Authorization': "Bearer #{token}" } }

  describe 'GET /index' do
    it 'returns empty list when no subscriptions' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe 'POST /create' do
    it 'creates a Stripe session for valid plan' do
      allow(Stripe::Checkout::Session).to receive(:create).and_return(OpenStruct.new(id: 'test_session_id'))

      post :create, params: { plan_type: 'weekly' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['session_id']).to eq('test_session_id')
    end

    it 'returns error for invalid plan_type' do
      post :create, params: { plan_type: 'invalid_plan' }
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid plan type')
    end
  end

  describe 'GET /success' do
    it 'creates a new active subscription' do
      get :success, params: { plan_type: 'weekly' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Subscription activated successfully')
    end

    it 'returns error if user not found' do
      # Simulate invalid token
      request.headers['Authorization'] = "Bearer invalidtoken"
      get :success, params: { plan_type: 'weekly' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /cancel' do
    it 'returns cancel message' do
      get :cancel
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Subscription process cancelled')
    end
  end

  describe 'GET /status' do
    context 'when active subscription exists and not expired' do
      before do
        user.user_subscriptions.create!(plan_type: 'weekly', status: 'active', expires_at: 2.days.from_now)
      end

      it 'returns current plan_type' do
        get :status
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['plan_type']).to eq('weekly')
      end
    end

    context 'when active subscription is expired' do
      before do
        user.user_subscriptions.create!(plan_type: 'weekly', status: 'active', expires_at: 2.days.ago)
      end

      it 'downgrades to 1-day and returns new plan' do
        get :status
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['plan_type']).to eq('daily')
      end
    end

    context 'when no active subscription' do
      it 'returns not found error' do
        get :status
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('No active subscription found')
      end
    end
  end
end
