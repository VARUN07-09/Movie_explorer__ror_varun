class Watchlist < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  validates :user_id, uniqueness: { scope: :movie_id, message: "already has this movie in their watchlist" }
end

