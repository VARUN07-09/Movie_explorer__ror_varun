class MakeSubscriptionPlanIdNullableInUserSubscriptions < ActiveRecord::Migration[7.1]
  def change
    change_column_null :user_subscriptions, :subscription_plan_id, true
  end
end
