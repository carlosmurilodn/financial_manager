class CreateUsersAndPasskeyCredentials < ActiveRecord::Migration[8.0]
  def up
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :email, null: false
        t.string :password_digest, null: false, default: ""
        t.string :webauthn_id
        t.timestamps
      end

      add_index :users, :email, unique: true
      add_index :users, :webauthn_id, unique: true
    end

    return if table_exists?(:passkey_credentials)

    create_table :passkey_credentials do |t|
      t.integer :user_id, null: false
      t.string :webauthn_id, null: false
      t.text :public_key, null: false
      t.integer :sign_count, null: false, default: 0
      t.string :nickname
      t.datetime :last_used_at
      t.timestamps
    end

    add_foreign_key :passkey_credentials, :users
    add_index :passkey_credentials, :user_id
    add_index :passkey_credentials, :webauthn_id, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
