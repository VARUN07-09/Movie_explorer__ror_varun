class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :plan_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
