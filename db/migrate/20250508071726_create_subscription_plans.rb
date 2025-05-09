class CreateSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_plans do |t|
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.integer :duration_months, null: false
      t.integer :plan_type, null: false, default: 0
      t.text :description

      t.timestamps
    end
  end
end