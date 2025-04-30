class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0 # 0: user, 1: supervisor

      t.timestamps
    end
  end
end