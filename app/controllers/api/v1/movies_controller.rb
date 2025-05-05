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
        @movie = Movie.new(movie_params)
        @movie.poster.attach(params[:poster]) if params[:poster].present?
        @movie.banner.attach(params[:banner]) if params[:banner].present?

        if @movie.save
          send_movie_creation_notification(@movie) # Send notification to all users
          render json: @movie, serializer: MovieSerializer, status: :created
        else
          render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        movie = Movie.find(params[:id])

        if movie.update(movie_params.except(:poster, :banner))
          movie.poster.purge && movie.poster.attach(params[:poster]) if params[:poster].present?
          movie.banner.purge && movie.banner.attach(params[:banner]) if params[:banner].present?

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

      private

      def send_movie_creation_notification(movie)
        # Fetch all users with an FCM token
        users_with_fcm_token = User.where.not(fcm_token: nil)

        # Notification message
        message = {
          notification: {
            title: "New Movie Released!",
            body: "Check out the new movie: #{movie.title}!"
          },
          data: {
            movie_id: movie.id.to_s,
            title: movie.title,
            genre: movie.genre
          }
        }

        # Send notification to each user with an FCM token
        users_with_fcm_token.each do |user|
          send_fcm_notification(user.fcm_token, message)
        end
      end

      def send_fcm_notification(fcm_token, message)
        # Initialize FCM with server key
        fcm = FCM.new(ENV['FCM_SERVER_KEY']) # Add your Firebase server key here
        response = fcm.send([fcm_token], message)
        Rails.logger.info "FCM Notification Response: #{response}"
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
