# app/models/user_subscription.rb
class UserSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan

  enum status: { active: 0, canceled: 1, expired: 2 }

  validates :subscription_plan_id, presence: true
  validates :user_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  # Allow searching on specific attributes
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "end_date", "id", "start_date", "status", "subscription_plan_id", "updated_at", "user_id"]
  end

  # Allow searching on the associations 'user' and 'subscription_plan'
  def self.ransackable_associations(auth_object = nil)
    ["subscription_plan", "user"]
  end

  # Method to check if subscription is still valid
  def valid_subscription?
    status == "active" && end_date > Time.current
  end
end
