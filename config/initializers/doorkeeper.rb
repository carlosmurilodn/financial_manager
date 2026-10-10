require Rails.root.join("lib/mcp_integration/settings")

McpIntegration::Settings.validate!

Doorkeeper.configure do
  orm :active_record
  resource_owner_authenticator do
    authenticate_user!
    current_user
  end
  admin_authenticator { head :forbidden }
  access_token_expires_in 15.minutes
  authorization_code_expires_in 5.minutes
  grant_flows %w[authorization_code]
  default_scopes McpIntegration::Settings::SCOPE
  enforce_configured_scopes
  force_pkce
  use_refresh_token
  hash_token_secrets
  hash_application_secrets
  custom_access_token_attributes [ :mcp_resource ]
end
