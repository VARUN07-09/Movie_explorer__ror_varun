# require 'rails_helper'

# RSpec.describe 'Api::V1::Movies', type: :request do
#   let(:user) { create(:user, role: :user) }
#   let(:admin) { create(:user, role: :admin) }
#   let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }
#   let(:admin_token) { JWT.encode({ user_id: admin.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }

#   describe 'GET /api/v1/movies' do
#     before do
#       Watchlist.delete_all
#       Movie.delete_all
#       create_list(:movie, 15)
#     end

#     it 'returns paginated movies without authentication' do
#       get '/api/v1/movies', params: { page: 1, per_page: 10 }
#       expect(response).to have_http_status(:ok)
#       json = JSON.parse(response.body)
#       expect(json['movies'].length).to eq(10)
#       expect(json['meta']['current_page']).to eq(1)
#       expect(json['meta']['total_pages']).to eq(2)
#       expect(json['meta']['total_count']).to eq(15)
#     end

#     it 'filters movies by search query' do
#       create(:movie, title: 'Avengers')
#       get '/api/v1/movies', params: { search: 'Avengers' }
#       expect(response).to have_http_status(:ok)
#       json = JSON.parse(response.body)
#       expect(json['movies'].map { |m| m['title'] }).to include('Avengers')
#     end
#   end

#   describe 'GET /api/v1/movies/:id' do
#     let(:movie) do
#       movie = create(:movie)
#       movie.poster.attach(
#         io: File.open(Rails.root.join('spec/fixtures/files/sample.jpg')),
#         filename: 'sample.jpg',
#         content_type: 'image/jpeg'
#       )
#       movie
#     end

#     after do
#       if movie.poster.attached?
#         movie.poster.blob.open { |file| file.close } rescue nil
#         movie.poster.purge
#       end
#     end

#     it 'returns movie with authentication' do
#       get "/api/v1/movies/#{movie.id}", headers: { 'Authorization' => "Bearer #{token}" }
#       expect(response).to have_http_status(:ok)
#       json = JSON.parse(response.body)
#       expect(json['id']).to eq(movie.id)
#       expect(json['poster_url']).to match(%r{https://res\.cloudinary\.com/dxddybvef/image/upload/.*\?_a=BACAEuBn})
#       # expect(json['poster_url']).to eq('https://cloudinary.com/sample.jpg')
#     end
#   end

#   describe 'POST /api/v1/movies' do
#     let(:movie_params) do
#       attributes_for(:movie).merge(
#         poster: fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg')
#       )
#     end

#     after do
#       if Movie.last&.poster&.attached?
#         Movie.last.poster.blob.open { |file| file.close } rescue nil
#         Movie.last.poster.purge
#       end
#     end

#     it 'creates movie as admin' do
#       post '/api/v1/movies', params: movie_params, headers: { 'Authorization' => "Bearer #{admin_token}" }
#       expect(response).to have_http_status(:created)
#       json = JSON.parse(response.body)
#       expect(json['title']).to eq(movie_params[:title])
#       expect(json['poster_url']).to match(%r{https://res\.cloudinary\.com/dxddybvef/image/upload/.*\?_a=BACAEuBn})
#       # expect(json['poster_url']).to eq('https://cloudinary.com/sample.jpg')
#     end
#   end
# end