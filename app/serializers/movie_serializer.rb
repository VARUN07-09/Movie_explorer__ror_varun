class MovieSerializer < ActiveModel::Serializer
  attributes :id, :title, :genre, :release_year, :rating, :director, :duration, :description, :premium, :poster_url, :banner_url

  def poster_url
    if object.poster.attached? && object.poster.key.present?
      Cloudinary::Utils.cloudinary_url(object.poster.key, resource_type: :image)
    else
      nil
    end
  end

  def banner_url
    if object.banner.attached? && object.banner.key.present?
      Cloudinary::Utils.cloudinary_url(object.banner.key, resource_type: :image)
    else
      nil
    end
  end
end