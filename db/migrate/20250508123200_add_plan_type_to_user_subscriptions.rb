class AddPlanTypeToUserSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :user_subscriptions, :plan_type, :string
  end
end
