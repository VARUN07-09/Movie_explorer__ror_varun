class AddStripeFieldsToUserSubscriptionsAndSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :user_subscriptions, :stripe_customer_id, :string
    add_column :user_subscriptions, :stripe_subscription_id, :string
    add_column :user_subscriptions, :expires_at, :datetime
    add_index :user_subscriptions, :expires_at

    add_column :subscription_plans, :stripe_price_id, :string
  end
end