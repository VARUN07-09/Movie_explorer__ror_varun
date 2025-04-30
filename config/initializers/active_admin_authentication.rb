# config/initializers/active_admin_authentication.rb

ActiveAdmin.setup do |config|
    config.site_title = "Movie Explorer+ Admin"
    
    config.authentication_method = :authenticate_admin_user!
    config.current_user_method = :current_admin_user
  
    config.logout_link_path = nil # Handle logout manually if needed
  
    config.comments = false
    config.batch_actions = true
    config.filter_attributes = [:encrypted_password, :password, :password_confirmation]
  end
    