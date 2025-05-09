class CreateUserSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end