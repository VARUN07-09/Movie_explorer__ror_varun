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
          movies: movies.map { |m| serialized_movie(m) },
          meta: {
            current_page: movies.current_page,
            total_pages: movies.total_pages,
            total_count: movies.total_count
          }
        }, status: :ok
      end

      def show
        movie = Movie.find(params[:id])
        render json: serialized_movie(movie), status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Movie not found' }, status: :not_found
      end

      def create
        movie = Movie.new(movie_params.except(:poster, :banner))
        
        # Attach poster if provided
        movie.poster.attach(params[:poster]) if params[:poster].present?
        # Attach banner if provided
        movie.banner.attach(params[:banner]) if params[:banner].present?

        if movie.save
          render json: movie, status: :created

        else
          render json: { errors: movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        movie = Movie.find(params[:id])

        # Update attributes
        if movie.update(movie_params.except(:poster, :banner))
          # Update poster if provided
          if params[:poster].present?
            movie.poster.purge
            movie.poster.attach(params[:poster])
          end
          # Update banner if provided
          if params[:banner].present?
            movie.banner.purge
            movie.banner.attach(params[:banner])
          end

          render json: serialized_movie(movie), status: :ok
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

      def authorize_admin_or_supervisor!
        unless current_user&.admin? || current_user&.supervisor?
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def movie_params
        # Remove the wrapping 'movie' key if you want to accept parameters directly at the root level
        params.permit(:title, :genre, :release_year, :rating, :description, :main_lead, :banner, :director, :streaming_platform, :duration, :premium, :poster)
      end

      def serialized_movie(movie)
        {
          id: movie.id,
          title: movie.title,
          genre: movie.genre,
          release_year: movie.release_year,
          rating: movie.rating,
          description: movie.description,
          main_lead: movie.main_lead,
          director: movie.director,
          streaming_platform: movie.streaming_platform,
          duration: movie.duration,
          premium: movie.premium,
          poster_url: movie.poster.attached? ? url_for(movie.poster) : nil,
          banner_url: movie.banner.attached? ? url_for(movie.banner) : nil,
          created_at: movie.created_at,
          updated_at: movie.updated_at
        }
      end
      
    end
  end
end
