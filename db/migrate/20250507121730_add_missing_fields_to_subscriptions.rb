class AddMissingFieldsToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    change_table :subscriptions do |t|
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.index [:end_date], name: "index_subscriptions_on_end_date"
    end
  end
end