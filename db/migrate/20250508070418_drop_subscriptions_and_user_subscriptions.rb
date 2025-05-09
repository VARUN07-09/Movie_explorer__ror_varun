class DropSubscriptionsAndUserSubscriptions < ActiveRecord::Migration[7.1]
  def change
    drop_table :subscriptions
    drop_table :user_subscriptions
  end
end
