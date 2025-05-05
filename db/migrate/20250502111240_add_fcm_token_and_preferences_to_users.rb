class AddFcmTokenAndPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :fcm_token, :string
    add_column :users, :notify_on_new_movie, :boolean
  end
end
