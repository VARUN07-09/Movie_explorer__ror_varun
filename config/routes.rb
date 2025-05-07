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
      post 'toggle_notifications', to: 'auth#toggle_notifications'
      post 'create_stripe_customer', to: 'auth#create_stripe_customer'

      # Movies
      resources :movies, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'search', to: 'movies#index'
          get 'watchlist', to: 'movies#watchlist'
          post 'toggle_watchlist', to: 'movies#toggle_watchlist'
        end
      end

      # Subscription Plans (publicly available)
      resources :subscription_plans, only: [:index, :show]

      # User Subscriptions
      resources :user_subscriptions, only: [:show] do
        collection do
          post :buy
        end
      end

      # Payments (Stripe)
      post 'payments/create', to: 'payments#create'

      # Notifications (for testing)
      post 'notifications/test', to: 'notifications#test'
    end
  end

  # Stripe webhook for payment confirmation
  post '/webhooks/stripe', to: 'stripe_webhooks#create'

  # Swagger Docs
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end