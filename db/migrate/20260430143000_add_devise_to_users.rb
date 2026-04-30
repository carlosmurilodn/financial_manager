class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :password_digest, from: nil, to: ""
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_column :users, :remember_created_at, :datetime

    execute <<~SQL.squish
      UPDATE users
      SET encrypted_password = password_digest
      WHERE encrypted_password = '' AND password_digest IS NOT NULL
    SQL
  end

  def down
    remove_column :users, :remember_created_at
    remove_column :users, :encrypted_password
    change_column_default :users, :password_digest, from: "", to: nil
  end
end
