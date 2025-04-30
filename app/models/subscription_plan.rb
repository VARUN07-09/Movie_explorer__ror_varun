# app/models/subscription_plan.rb
class SubscriptionPlan < ApplicationRecord
    has_many :user_subscriptions
  
    enum plan_type: { free: 0, basic: 1, premium: 2 }
  
    validates :name, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
    # Allow searching on specific attributes
    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "duration", "id", "name", "plan_type", "price", "updated_at"]
    end
  
    # Allow searching on the associated 'user_subscriptions'
    def self.ransackable_associations(auth_object = nil)
      ["user_subscriptions"]
    end
  end
  