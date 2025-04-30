# db/migrate/YYYYMMDDHHMMSS_create_user_subscriptions.rb
class CreateUserSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
