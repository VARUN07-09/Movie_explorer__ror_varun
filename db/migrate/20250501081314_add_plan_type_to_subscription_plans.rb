class AddPlanTypeToSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :subscription_plans, :plan_type, :integer
  end
end
