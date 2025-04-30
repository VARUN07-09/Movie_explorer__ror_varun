# db/migrate/YYYYMMDDHHMMSS_create_subscription_plans.rb
class CreateSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.float :price
      t.integer :duration_months
      t.text :description

      t.timestamps
    end
  end
end
