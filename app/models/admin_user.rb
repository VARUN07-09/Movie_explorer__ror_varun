class AdminUser < ApplicationRecord
  # Include Devise modules if applicable
  # devise :database_authenticatable, :recoverable, ...
  devise :database_authenticatable, :recoverable, :rememberable, :validatable


  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "created_at", "updated_at"]
  end
end
