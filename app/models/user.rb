class User < ApplicationRecord
  has_secure_password
  has_one :subscription, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :movies, through: :watchlists
  has_one_attached :profile_picture

  enum role: { user: 0, supervisor: 1, admin: 2 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  def profile_picture_url
    if profile_picture.attached?
      Cloudinary::Utils.cloudinary_url(profile_picture.key, resource_type: :image)
    else
      nil
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "created_at", "updated_at", "subscription_id"]
  end
end
