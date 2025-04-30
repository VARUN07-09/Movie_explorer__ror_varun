# class AdminUser < ApplicationRecord
#   # Include default devise modules. Others available are:
#   # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
#   devise :database_authenticatable, 
#          :recoverable, :rememberable, :validatable
# end

class AdminUser < ApplicationRecord
  # Include Devise modules if applicable
  # devise :database_authenticatable, :recoverable, ...
  devise :database_authenticatable, :recoverable, :rememberable, :validatable


  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "created_at", "updated_at"]
  end
end
