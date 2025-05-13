# require 'rails_helper'

# RSpec.describe Api::V1::UserSubscriptionsController, type: :controller do
#   let(:user) { create(:user, role: :user) }
#   let(:admin) { create(:user, role: :admin) }

#   let(:token) do
#     JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
#   end

#   let(:admin_token) do
#     JWT.encode({ user_id: admin.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
#   end

#   before do
#     request.headers['Content-Type'] = 'application/json'
#   end

#   def authorize(token)
#     request.headers['Authorization'] = "Bearer #{token}"
#   end

#   describe 'GET #index' do
#     before do
#       @sub1 = create(:user_subscription, user: user)
#       @sub2 = create(:user_subscription, user: user)
#       @sub3 = create(:user_subscription, user: create(:user))
#     end

#     context 'as admin' do
#       it 'returns all user subscriptions' do
#         authorize(admin_token)
#         get :index
#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['subscriptions']).to be_an(Array)
#         expect(json['subscriptions'].size).to eq(3)
#       end
#     end

#     context 'as normal user' do
#       it 'returns only user’s subscriptions' do
#         authorize(token)
#         get :index
#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['subscriptions'].size).to eq(2)
#         expect(json['subscriptions'].all? { |s| s['user_id'] == user.id }).to be true
#       end
#     end
#   end
# end
