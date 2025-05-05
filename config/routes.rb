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

      # Update FCM token
      patch 'auth/update_fcm_token', to: 'auth#update_fcm_token'

      # Update notification preferences
      patch 'auth/notifications/preferences', to: 'auth#update_notification_preferences'

      # Movies
      resources :movies, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'search', to: 'movies#index'
        end
      end

      # Subscriptions (user-specific)
      resources :subscriptions, only: [:index, :show, :create, :update, :destroy]

      # Subscription Plans (publicly available)
      resources :subscription_plans, only: [:index, :show]

      # User Subscriptions
      resources :user_subscriptions, only: [:show] do
        collection do
          post :buy  # /api/v1/user_subscriptions/buy
        end
      end

      # Payments (Stripe)
      post 'payments/create', to: 'payments#create'

      # Notifications
      post 'notifications/test', to: 'notifications#test' # For testing notifications

    end
  end

  # Stripe webhook for payment confirmation
  post '/webhooks/stripe', to: 'stripe_webhooks#create'

  # Swagger Docs
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end
