class MovieSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :title, :genre, :release_year, :rating, :description,
             :main_lead, :director, :streaming_platform, :duration, :premium,
             :poster_url, :banner_url, :created_at, :updated_at

  def poster_url
    object.poster.attached? ? rails_blob_url(object.poster, only_path: true) : nil
  end

  def banner_url
    object.banner.attached? ? rails_blob_url(object.banner, only_path: true) : nil
  end
end
