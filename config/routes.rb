
Rails.application.routes.draw do
  # Admin & Devise
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: redirect('/admin')

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'signup', to: 'auth#signup'
      post 'login', to: 'auth#login'
      post 'update_device_token', to: 'auth#update_device_token'
      get 'user', to: 'auth#show'
      post 'update_profile_picture', to: 'auth#update_profile_picture'
      post 'toggle_notifications', to: 'auth#toggle_notifications'
      # Movies
      resources :movies, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'search', to: 'movies#index'
          get 'watchlist', to: 'movies#watchlist'
          post 'toggle_watchlist', to: 'movies#toggle_watchlist'
        end
      end

      # User Subscriptions
      resources :user_subscriptions, only: [:index, :create] do
        collection do
          get 'success', to: 'user_subscriptions#success'
          get 'cancel', to: 'user_subscriptions#cancel'
          get 'status', to: 'user_subscriptions#status'
        end
      end

      # Subscription Plans (assuming a SubscriptionPlansController exists)
      resources :subscription_plans, only: [:index, :show]
    end
  end

  # Swagger Docs
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end