class DropSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    drop_table :subscription_plans
  end
end
