# frozen_string_literal: true

class AddDeviseToAdminUsers < ActiveRecord::Migration[7.1]
  def self.up
    # Use `column_exists?` to avoid adding columns that already exist
    change_table :admin_users do |t|
      t.string   :reset_password_token unless column_exists?(:admin_users, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:admin_users, :reset_password_sent_at)
      t.datetime :remember_created_at unless column_exists?(:admin_users, :remember_created_at)

      # You can add more here conditionally if needed
    end

    # Safe indexing: check if index exists before adding
    unless index_exists?(:admin_users, :reset_password_token)
      add_index :admin_users, :reset_password_token, unique: true
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
