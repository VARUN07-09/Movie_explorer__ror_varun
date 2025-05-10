module Api
  module V1
    class MoviesController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy, :toggle_watchlist]
      before_action :authorize_request, except: [:index]
      before_action :set_movie, only: [:show, :update, :destroy]
      before_action :authorize_admin_or_supervisor, only: [:create, :update, :destroy]

      def index
        movies = Movie.all
        movies = movies.search(params[:search]) if params[:search].present?
        movies = movies.where(genre: params[:genre]) if params[:genre].present?
        movies = movies.where('rating >= ?', params[:rating]) if params[:rating].present?
        movies = movies.where(release_year: params[:release_year]) if params[:release_year].present?
      
        paginated_movies = movies.page(params[:page]).per(10)
        render json: {
          movies: ActiveModelSerializers::SerializableResource.new(
            paginated_movies,
            each_serializer: MovieSerializer
          ).as_json,
          meta: {
            current_page: paginated_movies.current_page,
            total_pages: paginated_movies.total_pages,
            total_count: paginated_movies.total_count
          }
        }, status: :ok
      end
      def show
        render json: ActiveModelSerializers::SerializableResource.new(
          @movie,
          serializer: MovieSerializer
        ).as_json, status: :ok
      end

      def create
        movie = Movie.new(movie_params.except(:poster, :banner))
        movie.poster.attach(params[:poster]) if params[:poster].present?
        movie.banner.attach(params[:banner]) if params[:banner].present?

        if movie.save
          render json: movie.as_json(except: [:created_at, :updated_at], methods: [:poster_url, :banner_url]), status: :created
        else
          render json: { errors: movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @movie.update(movie_params.except(:poster, :banner))
          @movie.poster.attach(params[:poster]) if params[:poster].present?
          @movie.banner.attach(params[:banner]) if params[:banner].present?
          render json: @movie.as_json(except: [:created_at, :updated_at], methods: [:poster_url, :banner_url]), status: :ok
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @movie.destroy
        render json: { message: 'Movie deleted successfully' }, status: :ok
      end

      
      def watchlist
        movies = @current_user.movies
        render json: {
          movies: ActiveModelSerializers::SerializableResource.new(
            movies,
            each_serializer: MovieSerializer
          ).as_json
        }, status: :ok
      end

      def toggle_watchlist
        movie = Movie.find_by(id: params[:movie_id])
        unless movie
          return render json: { error: 'Movie not found' }, status: :not_found
        end

        watchlist = @current_user.watchlists.find_or_initialize_by(movie: movie)
        if watchlist.persisted?
          watchlist.destroy
          render json: { message: 'Movie removed from watchlist' }, status: :ok
        else
          watchlist.save
          render json: { message: 'Movie added to watchlist' }, status: :created
        end
      end

      private

      def set_movie
        @movie = Movie.find_by(id: params[:id])
        render json: { error: 'Movie not found' }, status: :not_found unless @movie
      end

      def movie_params
        params.permit(:title, :genre, :release_year, :rating, :director, :duration, :streaming_platform, :main_lead, :description, :premium, :poster, :banner)
      end

      def authorize_admin_or_supervisor
        unless @current_user&.role&.in?(['admin', 'supervisor'])
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end