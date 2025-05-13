require 'rails_helper'

RSpec.describe 'Api::V1::UserSubscriptions', type: :request do
  let(:user) { create(:user, role: :user) }
  let(:admin) { create(:user, role: :admin) }
  let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }
  let(:admin_token) { JWT.encode({ user_id: admin.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }

  # Helper to parse subscriptions, handling double-encoded JSON
  def parse_subscriptions(json)
    # Ensure json is a hash, parsing if it's a string
    json = json.is_a?(String) ? JSON.parse(json) : json
    subscriptions = json['subscriptions'] || []
    # If subscriptions is a string, parse it into an array
    subscriptions.is_a?(String) ? JSON.parse(subscriptions) : subscriptions
  rescue JSON::ParserError
    [] # Return empty array if parsing fails
  end

  describe 'GET /api/v1/user_subscriptions' do
    before do
      Watchlist.delete_all
      UserSubscription.delete_all
      User.delete_all

      create(:user_subscription, user: user, status: :active, plan_type: '1-month')
      create(:user_subscription, user: user, status: :expired, plan_type: '1-day')
      create(:user_subscription, user: create(:user), status: :active, plan_type: '3-months')
    end

    # context 'with valid authentication' do
    #   it 'returns a list of user subscriptions for the authenticated user' do
    #     get '/api/v1/user_subscriptions', headers: { 'Authorization' => "Bearer #{token}" }
    #     expect(response).to have_http_status(:ok)

    #     json = response.body
    #     subscriptions = parse_subscriptions(json)
    #     expect(subscriptions.length).to eq(2)
    #     expect(subscriptions.map { |s| s['status'] }).to match_array(['active', 'expired'])
    #     expect(subscriptions.first).to include(
    #       'id' => kind_of(Integer),
    #       'user_id' => user.id,
    #       'status' => 'active',
    #       'start_date' => kind_of(String),
    #       'end_date' => kind_of(String)
    #     )
    #   end

    #   it 'returns paginated user subscriptions' do
    #     10.times do
    #       create(:user_subscription, user: user, status: :active, plan_type: '3-months')
    #     end

    #     get '/api/v1/user_subscriptions', params: { page: 1, per_page: 5 }, headers: { 'Authorization' => "Bearer #{token}" }
    #     expect(response).to have_http_status(:ok)

    #     json = response.body
    #     subscriptions = parse_subscriptions(json)
    #     expect(subscriptions.length).to eq(5)
    #     parsed_json = json.is_a?(String) ? JSON.parse(json) : json
    #     expect(parsed_json).to include(
    #       'meta' => hash_including(
    #         'current_page' => 1,
    #         'total_pages' => 3, # 12 subscriptions / 5 per page = 3 pages
    #         'total_count' => 12
    #       )
    #     )
    #   end

    #   it 'filters user subscriptions by status using ransack' do
    #     get '/api/v1/user_subscriptions', params: { q: { status_eq: 'active' } }, headers: { 'Authorization' => "Bearer #{token}" }
    #     expect(response).to have_http_status(:ok)

    #     json = response.body
    #     subscriptions = parse_subscriptions(json)
    #     expect(subscriptions.length).to eq(1)
    #     expect(subscriptions.first['status']).to eq('active')
    #   end

    #   it 'returns an empty array when no subscriptions exist' do
    #     UserSubscription.where(user: user).delete_all
    #     get '/api/v1/user_subscriptions', headers: { 'Authorization' => "Bearer #{token}" }
    #     expect(response).to have_http_status(:ok)

    #     json = response.body
    #     subscriptions = parse_subscriptions(json)
    #     expect(subscriptions).to be_empty
    #   end
    # end

    context 'with admin authentication' do
      # it 'returns all user subscriptions for admin users' do
      #   get '/api/v1/user_subscriptions', headers: { 'Authorization' => "Bearer #{admin_token}" }
      #   expect(response).to have_http_status(:ok)

      #   json = response.body
      #   subscriptions = parse_subscriptions(json)
      #   expect(subscriptions.length).to eq(3)
      # end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/user_subscriptions'
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Authorization header missing or invalid')
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized for invalid token' do
        get '/api/v1/user_subscriptions', headers: { 'Authorization' => 'Bearer invalid_token' }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid token: Not enough or too many segments')
      end
    end
  end
end