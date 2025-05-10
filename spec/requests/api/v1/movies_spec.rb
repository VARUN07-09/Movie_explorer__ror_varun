require 'rails_helper'

RSpec.describe 'Api::V1::Movies', type: :request do
  let(:user) { create(:user, role: :user) }
  let(:admin) { create(:user, role: :admin) }
  let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }
  let(:admin_token) { JWT.encode({ user_id: admin.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }
  let(:movie) { create(:movie) }

  describe 'GET /api/v1/movies' do
    before do
      create_list(:movie, 15)
      allow(Cloudinary::Uploader).to receive(:upload).and_return({ 'secure_url' => 'https://cloudinary.com/sample.jpg' })
    end

    it 'returns paginated movies without authentication' do
      get '/api/v1/movies', params: { page: 1 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['movies'].length).to eq(10)
      expect(json['meta']['current_page']).to eq(1)
      expect(json['meta']['total_pages']).to eq(2)
      expect(json['meta']['total_count']).to eq(15)
      expect(json['movies'].first['poster_url']).to eq('https://cloudinary.com/sample.jpg')
    end

    it 'filters movies by search query' do
      create(:movie, title: 'Avengers')
      get '/api/v1/movies', params: { search: 'Avengers' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['movies'].first['title']).to eq('Avengers')
    end
  end

  describe 'GET /api/v1/movies/:id' do
    before { allow(Cloudinary::Uploader).to receive(:upload).and_return({ 'secure_url' => 'https://cloudinary.com/sample.jpg' }) }

    it 'returns movie with authentication' do
      get "/api/v1/movies/#{movie.id}", headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(movie.id)
      expect(json['poster_url']).to eq('https://cloudinary.com/sample.jpg')
    end

    it 'returns unauthorized without token' do
      get "/api/v1/movies/#{movie.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/movies' do
    let(:movie_params) { attributes_for(:movie).merge(poster: fixture_file_upload(Rails.root.join('spec/support/fixtures/sample.jpg'), 'image/jpeg')) }

    before { allow(Cloudinary::Uploader).to receive(:upload).and_return({ 'secure_url' => 'https://cloudinary.com/sample.jpg' }) }

    it 'creates movie as admin' do
      post '/api/v1/movies', params: movie_params, headers: { 'Authorization' => "Bearer #{admin_token}" }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['title']).to eq(movie_params[:title])
      expect(json['poster_url']).to eq('https://cloudinary.com/sample.jpg')
    end

    it 'returns unauthorized for non-admin' do
      post '/api/v1/movies', params: movie_params, headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end