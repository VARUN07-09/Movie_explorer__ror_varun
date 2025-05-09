class ChangeStatusColumnInUserSubscriptions < ActiveRecord::Migration[6.0]
  def change
    change_column_null :user_subscriptions, :status, true
  end
end
