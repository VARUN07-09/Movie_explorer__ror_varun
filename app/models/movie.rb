class Movie < ApplicationRecord
  include Rails.application.routes.url_helpers

  validates :title, presence: true, uniqueness: true 
  validates :genre, presence: true
  validates :release_year, presence: true, numericality: { only_integer: true, greater_than: 1880 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  has_many :watchlists, dependent: :destroy
  has_many :users, through: :watchlists
  has_one_attached :poster
  has_one_attached :banner
  validates :poster, content_type: ['image/png', 'image/jpeg'], size: { less_than: 5.megabytes }

  def poster_url
    if poster.attached?
      Cloudinary::Utils.cloudinary_url(poster.key, resource_type: :image)
    else
      nil
    end
  end

  def banner_url
    if banner.attached?
      Cloudinary::Utils.cloudinary_url(banner.key, resource_type: :image)
    else
      nil
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "genre", "id", "id_value", "poster", "rating", "release_year", "title", "updated_at"]
  end
end