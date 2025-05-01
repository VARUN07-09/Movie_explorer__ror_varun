class User < ApplicationRecord
  has_secure_password
  has_one :subscription, dependent: :destroy

  enum role: { user: 0, supervisor: 1, admin: 2 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "created_at", "updated_at", "subscription_id"]
  end
end
