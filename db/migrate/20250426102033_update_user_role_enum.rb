# db/migrate/YYYYMMDDHHMMSS_update_user_role_enum.rb
class UpdateUserRoleEnum < ActiveRecord::Migration[7.1]
  def up
    change_column_default :users, :role, from: 0, to: 0
    # No need to modify the enum values in the DB; Rails handles enums in the model
  end

  def down
    change_column_default :users, :role, from: 0, to: 0
  end
end