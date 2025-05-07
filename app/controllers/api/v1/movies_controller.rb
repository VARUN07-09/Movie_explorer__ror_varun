module Api
  module V1
    class MoviesController < ApplicationController
      include Authenticable
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user, only: [:index, :show]

      before_action :authorize_admin_or_supervisor!, only: [:create, :update, :destroy]

      def index
        movies = Movie.all
        movies = movies.where('title ILIKE ?', "%#{params[:search]}%") if params[:search].present?
        movies = movies.where(genre: params[:genre]) if params[:genre].present?
        movies = movies.where('rating > ?', params[:rating]) if params[:rating].present?
        movies = movies.where('extract(year from release_date) = ?', params[:release_year]) if params[:release_year].present?
        movies = movies.page(params[:page]).per(10)

        render json: {
          movies: ActiveModelSerializers::SerializableResource.new(movies, each_serializer: MovieSerializer),
          meta: {
            current_page: movies.current_page,
            total_pages: movies.total_pages,
            total_count: movies.total_count
          }
        }, status: :ok
      end

      def show
        movie = Movie.find(params[:id])
        render json: movie, serializer: MovieSerializer, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Movie not found' }, status: :not_found
      end

      def create
        @movie = Movie.new(movie_params.except(:poster, :banner))
        @movie.poster.attach(params[:poster]) if params[:poster].present?
        @movie.banner.attach(params[:banner]) if params[:banner].present?

        if @movie.save
          send_new_movie_notification(@movie)
          render json: @movie, serializer: MovieSerializer, status: :created
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        movie = Movie.find(params[:id])
        if movie.update(movie_params.except(:poster, :banner))
          if params[:poster].present?
            movie.poster.purge
            movie.poster.attach(params[:poster])
          end
          if params[:banner].present?
            movie.banner.purge
            movie.banner.attach(params[:banner])
          end
          movie.reload
          render json: movie, serializer: MovieSerializer, status: :ok
        else
          render json: { errors: movie.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Movie not found' }, status: :not_found
      end

      def destroy
        movie = Movie.find(params[:id])
        if movie.destroy
          render json: { message: "Movie deleted successfully" }, status: :ok
        else
          render json: { error: "Failed to delete movie" }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Movie not found' }, status: :not_found
      end

      # Get all movies in the user's watchlist
      def watchlist
        watchlist_movies = current_user.movies
        render json: {
          movies: ActiveModelSerializers::SerializableResource.new(watchlist_movies, each_serializer: MovieSerializer)
        }, status: :ok
      end

      # Toggle movie in the user's watchlist (add/remove)
      def toggle_watchlist
        movie = Movie.find_by(id: params[:movie_id])

        if movie.nil?
          return render json: { error: "Movie not found" }, status: :not_found
        end

        # Check if the movie is already in the watchlist
        watchlist_item = current_user.watchlists.find_by(movie_id: movie.id)

        if watchlist_item
          # Movie is in the watchlist, so remove it
          watchlist_item.destroy
          render json: { message: "Movie removed from watchlist" }, status: :ok
        else
          # Movie is not in the watchlist, so add it
          current_user.watchlists.create(movie: movie)
          render json: { message: "Movie added to watchlist" }, status: :created
        end
      end

      private

      def send_new_movie_notification(movie)
        users = User.where(notifications_enabled: true).where.not(device_token: [nil, ""])
        return if users.empty?

        device_tokens = users.pluck(:device_token)
        begin
          fcm_service = FcmService.new
          fcm_service.send_notification(
            device_tokens,
            "New Movie Added!",
            "#{movie.title} has been added to the Movie Explorer collection.",
            { movie_id: movie.id.to_s }
          )
        rescue StandardError => e
          Rails.logger.error "FCM Notification Failed: #{e.message}"
        end
      end

      def authorize_admin_or_supervisor!
        unless current_user&.admin? || current_user&.supervisor?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def movie_params
        params.permit(:title, :genre, :release_year, :rating, :description,
                      :main_lead, :director, :streaming_platform, :duration,
                      :premium, :poster, :banner)
      end
    end
  end
end
