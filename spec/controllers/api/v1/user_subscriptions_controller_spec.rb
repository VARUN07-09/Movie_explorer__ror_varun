require 'rails_helper'

RSpec.describe Api::V1::UserSubscriptionsController, type: :controller do
  before do
    request.headers['Content-Type'] = 'application/json'
    request.headers.merge!(auth_headers)
    # Stub authorize_request and set @current_user
    allow(controller).to receive(:authorize_request).and_return(true)
    controller.instance_variable_set(:@current_user, user)
    # Stub environment variables for Stripe price IDs
    allow(ENV).to receive(:[]).with('One_DAY_ID').and_return('price_1day')
    allow(ENV).to receive(:[]).with('One_MONTH_ID').and_return('price_1month')
    allow(ENV).to receive(:[]).with('Three_MONTHS_ID').and_return('price_3months')
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
      allow(Stripe::Checkout::Session).to receive(:create).and_return(OpenStruct.new(id: 'test_session_id', url: 'https://checkout.stripe.com/test'))

      post :create, params: { plan_type: '1-month' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['session_id']).to eq('test_session_id')
    end

    it 'returns error for invalid plan_type' do
      post :create, params: { plan_type: 'invalid_plan' }
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid or missing plan_type')
    end
  end

  describe 'GET /success' do
    let(:stripe_session) do
      OpenStruct.new(
        id: 'test_session_id',
        customer: 'cus_123',
        payment_intent: 'pi_123',
        metadata: { 'user_id' => user.id, 'plan_type' => '1-month' }
      )
    end

    before do
      allow(Stripe::Checkout::Session).to receive(:retrieve).with('test_session_id').and_return(stripe_session)
    end

    it 'creates a new active subscription' do
      get :success, params: { session_id: 'test_session_id', plan_type: '1-month' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Subscription created successfully')
      expect(user.user_subscriptions.last.status).to eq('active')
    end

    it 'returns error if user not found' do
      allow(Stripe::Checkout::Session).to receive(:retrieve).with('test_session_id').and_return(
        OpenStruct.new(
          id: 'test_session_id',
          customer: 'cus_123',
          payment_intent: 'pi_123',
          metadata: { 'user_id' => 'invalid_id', 'plan_type' => '1-month' }
        )
      )
      get :success, params: { session_id: 'test_session_id', plan_type: '1-month' }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('User not found')
    end
  end

  describe 'GET /cancel' do
    it 'returns cancel message' do
      get :cancel
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Payment cancelled')
    end
  end

  describe 'GET /status' do
    context 'when active subscription exists and not expired' do
      before do
        user.user_subscriptions.create!(
          plan_type: '1-month',
          status: 'active',
          start_date: Date.today,
          end_date: Date.today + 30.days,
          expires_at: 2.days.from_now
        )
      end

      it 'returns current plan_type' do
        get :status
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['plan_type']).to eq('1-month')
      end
    end

    context 'when active subscription is expired' do
      before do
        user.user_subscriptions.create!(
          plan_type: '1-month',
          status: 'active',
          start_date: Date.today - 30.days,
          end_date: Date.today - 2.days,
          expires_at: 2.days.ago
        )
      end

      it 'downgrades to 1-day and returns new plan' do
        get :status
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['plan_type']).to eq('1-day')
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