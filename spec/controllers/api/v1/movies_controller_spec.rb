require 'rails_helper'


def encode_token(user_id)
  JWT.encode({ user_id: user_id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
end

RSpec.describe Api::V1::MoviesController, type: :controller do
  let(:user) { create(:user, role: :user) }
  let(:admin) { create(:user, role: :admin) }
  let(:supervisor) { create(:user, role: :supervisor) }
  let(:movie) { create(:movie) }

  before do
    Watchlist.delete_all 
    Movie.delete_all
  end

  describe 'GET /api/v1/movies' do
    context 'without filters' do
      it 'returns a paginated list of movies' do
        create_list(:movie, 15)
        get :index, params: { page: 1 }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(10) 
        expect(json['meta']['current_page']).to eq(1)
        expect(json['meta']['total_pages']).to eq(2) 
        expect(json['meta']['total_count']).to eq(15)
      end
    end

    context 'with search filter' do
      it 'returns filtered movies' do
        create(:movie, title: 'Inception')
        create(:movie, title: 'Avatar')
        get :index, params: { search: 'Inception' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(1)
        expect(json['movies'][0]['title']).to eq('Inception')
      end

      it 'returns all movies for empty search' do
        create_list(:movie, 5)
        get :index, params: { search: '' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(5)
      end
    end

    context 'with genre filter' do
      it 'returns movies by genre' do
        create(:movie, genre: 'Action')
        create(:movie, genre: 'Drama')
        get :index, params: { genre: 'Action' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(1)
        expect(json['movies'][0]['genre']).to eq('Action')
      end
    end

    context 'with rating filter' do
      it 'returns movies with minimum rating' do
        create(:movie, rating: 8.0)
        create(:movie, rating: 6.0)
        get :index, params: { rating: 7.0 }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(1)
        expect(json['movies'][0]['rating']).to eq('8.0') # Expect string
      end
    end

    context 'with release_year filter' do
      it 'returns movies by release year' do
        create(:movie, release_year: 2020)
        create(:movie, release_year: 2019)
        get :index, params: { release_year: 2020 }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(1)
        expect(json['movies'][0]['release_year']).to eq(2020)
      end
    end
  end

  describe 'GET /api/v1/movies/:id' do
    context 'with valid movie id' do
      it 'returns the movie' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        get :show, params: { id: movie.id }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['title']).to eq(movie.title)
      end
    end

    context 'with invalid movie id' do
      it 'returns not found' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        get :show, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Movie not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get :show, params: { id: movie.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
      end
    end

    context 'with invalid JWT token' do
      it 'returns unauthorized' do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :show, params: { id: movie.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid token: Not enough or too many segments')
      end
    end
  end

  describe 'POST /api/v1/movies' do
    let(:valid_params) do
      {
        title: 'New Movie',
        genre: 'Action',
        release_year: 2023,
        rating: 7.5,
        director: 'John Doe',
        duration: 120,
        streaming_platform: 'Netflix',
        main_lead: 'Jane Doe',
        description: 'A thrilling movie',
        premium: false
      }
    end

    context 'as admin' do
      it 'creates a new movie' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('New Movie')
        expect(json['poster_url']).to be_nil
        expect(json['banner_url']).to be_nil
      end
    end

    context 'as supervisor' do
      it 'creates a new movie' do
        token = encode_token(supervisor.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'as regular user' do
      it 'returns unauthorized' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :create, params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity for missing genre' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :create, params: valid_params.except(:genre)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Genre can't be blank")
      end

      it 'returns unprocessable entity for invalid release_year' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :create, params: valid_params.merge(release_year: 1800)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Release year must be greater than 1880")
      end
    end
  end

  describe 'PUT /api/v1/movies/:id' do
    let(:update_params) do
      { title: 'Updated Movie' }
    end

    context 'as admin' do
      it 'updates the movie' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        put :update, params: { id: movie.id, **update_params }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('Updated Movie')
      end
    end

    context 'as supervisor' do
      it 'updates the movie' do
        token = encode_token(supervisor.id)
        request.headers['Authorization'] = "Bearer #{token}"
        put :update, params: { id: movie.id, **update_params }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as regular user' do
      it 'returns unauthorized' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        put :update, params: { id: movie.id, **update_params }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid movie id' do
      it 'returns not found' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        put :update, params: { id: 999, **update_params }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Movie not found')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity for blank title' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        put :update, params: { id: movie.id, title: '' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'DELETE /api/v1/movies/:id' do
    context 'as admin' do
      it 'deletes the movie' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        delete :destroy, params: { id: movie.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Movie deleted successfully')
        expect(Movie.exists?(movie.id)).to be_falsey
      end
    end

    context 'as supervisor' do
      it 'deletes the movie' do
        token = encode_token(supervisor.id)
        request.headers['Authorization'] = "Bearer #{token}"
        delete :destroy, params: { id: movie.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as regular user' do
      it 'returns unauthorized' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        delete :destroy, params: { id: movie.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid movie id' do
      it 'returns not found' do
        token = encode_token(admin.id)
        request.headers['Authorization'] = "Bearer #{token}"
        delete :destroy, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Movie not found')
      end
    end
  end

  describe 'GET /api/v1/movies/watchlist' do
    context 'with movies in watchlist' do
      it 'returns user’s watchlist' do
        watchlist = create(:watchlist, user: user, movie: movie)
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        get :watchlist
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies'].size).to eq(1)
        expect(json['movies'][0]['title']).to eq(movie.title)
      end
    end

    context 'with empty watchlist' do
      it 'returns empty watchlist' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        get :watchlist
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['movies']).to be_empty
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get :watchlist
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
      end
    end
  end

  describe 'POST /api/v1/movies/toggle_watchlist' do
    context 'adding movie to watchlist' do
      it 'adds movie to watchlist' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_watchlist, params: { movie_id: movie.id }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Movie added to watchlist')
        expect(user.watchlists.find_by(movie_id: movie.id)).to be_present
      end
    end

    context 'removing movie from watchlist' do
      it 'removes movie from watchlist' do
        create(:watchlist, user: user, movie: movie)
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_watchlist, params: { movie_id: movie.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Movie removed from watchlist')
        expect(user.watchlists.find_by(movie_id: movie.id)).to be_nil
      end
    end

    context 'with invalid movie id' do
      it 'returns not found' do
        token = encode_token(user.id)
        request.headers['Authorization'] = "Bearer #{token}"
        post :toggle_watchlist, params: { movie_id: 999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Movie not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post :toggle_watchlist, params: { movie_id: movie.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Authorization header missing or invalid')
      end
    end
  end
end