class UserSubscription < ApplicationRecord
  belongs_to :user
  enum status: { pending: 0, active: 1, expired: 2, canceled: 3 }
  validates :start_date, :end_date, :status, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "subscription_plan_id", "start_date", "end_date", "status", "created_at", "updated_at", "stripe_customer_id", "stripe_subscription_id", "expires_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "subscription_plan"]
  end
end