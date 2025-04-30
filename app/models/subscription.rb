class Subscription < ApplicationRecord
  belongs_to :user

  enum plan_type: { free: 0, basic: 1, premium: 2 }
  enum status: { active: 0, canceled: 1 }

  validates :plan_type, :status, :start_date, :end_date, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "plan_type", "status", "user_id", "start_date", "end_date", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
