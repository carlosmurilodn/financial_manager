class CreateMcpOauthTables < ActiveRecord::Migration[8.0]
  def change
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: "writing_studio:read"
      t.boolean :confidential, null: false, default: true
      t.timestamps null: false
    end
    add_index :oauth_applications, :uid, unique: true
    create_table :oauth_access_grants do |t|
      t.bigint :resource_owner_id, null: false
      t.references :application, null: false, foreign_key: { to_table: :oauth_applications }
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ""
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :code_challenge
      t.string :code_challenge_method
      t.string :mcp_resource, null: false
    end
    add_index :oauth_access_grants, :resource_owner_id
    add_index :oauth_access_grants, :token, unique: true
    add_foreign_key :oauth_access_grants, :users, column: :resource_owner_id, on_delete: :cascade
    create_table :oauth_access_tokens do |t|
      t.bigint :resource_owner_id, null: false
      t.references :application, null: false, foreign_key: { to_table: :oauth_applications }
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in, null: false
      t.string :scopes, null: false, default: ""
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :mcp_resource, null: false
    end
    add_index :oauth_access_tokens, :resource_owner_id
    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id, on_delete: :cascade
    reversible do |direction|
      direction.up do
        %w[oauth_applications oauth_access_grants oauth_access_tokens].each do |table|
          execute "ALTER TABLE #{table} ENABLE ROW LEVEL SECURITY"
        end
      end
    end
  end
end
