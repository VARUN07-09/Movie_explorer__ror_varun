# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :user_subscriptions, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :movies, through: :watchlists
  has_one_attached :profile_picture
  after_create :create_stripe_customer

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

  def create_stripe_customer
    customer = Stripe::Customer.create(
      email: email,
      name: name
    )
    update!(stripe_customer_id: customer.id)
    Rails.logger.info("Stripe customer created for user #{id}: #{customer.id}")
  rescue Stripe::StripeError => e
    Rails.logger.error("Failed to create Stripe customer for user #{id}: #{e.message}")
    nil
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "name", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user_subscriptions", "watchlists", "movies"]
  end
end