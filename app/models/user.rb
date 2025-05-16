class User < ApplicationRecord
  has_secure_password
  has_many :user_subscriptions, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :movies, through: :watchlists
  has_one_attached :profile_picture
  # after_create :create_default_subscription

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

  def create_default_subscription
    Rails.logger.info("Creating default subscription for user: #{email}")
    begin
      customer = Stripe::Customer.create(email: email)
      free_plan = SubscriptionPlan.find_by(plan_type: :free) || SubscriptionPlan.create!(
        name: "Free Plan",
        price: 0,
        duration_months: 12,
        plan_type: :free,
        stripe_price_id: nil
      )
      user_subscriptions.create!(
        subscription_plan: free_plan,
        start_date: Date.today,
        end_date: Date.today + free_plan.duration_months.months,
        status: :active,
        stripe_customer_id: customer.id
      )
      Rails.logger.info("Default subscription created for user: #{email}")
    rescue Stripe::StripeError => e
      Rails.logger.error("Failed to create Stripe customer for user #{id}: #{e.message}")
      free_plan = SubscriptionPlan.find_by(plan_type: :free) || SubscriptionPlan.create!(
        name: "Free Plan",
        price: 0,
        duration_months: 12,
        plan_type: :free,
        stripe_price_id: nil
      )
      user_subscriptions.create!(
        subscription_plan: free_plan,
        start_date: Date.today,
        end_date: Date.today + free_plan.duration_months.months,
        status: :active
      )
      Rails.logger.info("Default subscription created without Stripe for user: #{email}")
    rescue StandardError => e
      Rails.logger.error("Failed to create default subscription for user #{id}: #{e.message}")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "name", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user_subscriptions", "watchlists", "movies"]
  end
end